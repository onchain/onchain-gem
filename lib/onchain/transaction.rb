class OnChain::Transaction
  class << self
    
    DUST_SATOSHIES = 548
    MINERS_BYTE_FEE = 100
    CACHE_KEY = 'Bitcoin21Fees'
    CACHE_FOR = 10 # 10 minutes, roughly each block.
      
    def calculate_miners_fee(addresses, amount, network = :bitcoin)
      
      tx_size = estimate_transaction_size(addresses, amount, network)
      
      # If it's not bitcoin then just give it a realatively low fee
      tx_fee = MINERS_BYTE_FEE
      if network == :bitcoin
        tx_fee = get_recommended_tx_fee["fastestFee"]
      end
      
      return tx_size * tx_fee
      
    end
    
    def get_recommended_tx_fee
      
      begin
      
        if OnChain::BlockChain.cache_read(CACHE_KEY) == nil
          fees = OnChain::BlockChain.fetch_response('https://bitcoinfees.21.co/api/v1/fees/recommended', true)
          OnChain::BlockChain.cache_write(CACHE_KEY, fees, CACHE_FOR)
        end
        
        return OnChain::BlockChain.cache_read(CACHE_KEY)
      rescue
        fees = {"fastestFee" => 200,"halfHourFee" => 180,"hourFee" => 160}
        OnChain::BlockChain.cache_write(CACHE_KEY, fees, CACHE_FOR)
        return OnChain::BlockChain.cache_read(CACHE_KEY)
      end
    end
    
    # http://bitcoin.stackexchange.com/questions/1195/how-to-calculate-transaction-size-before-sending
    # in*148 + out*34 + 10 plus or minus 'in'
    def estimate_transaction_size(addresses, amount, network = :bitcoin)
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(addresses, amount, network)
      indexes ,change = nil
      
      # Assume each input is 275 bytes.
      size_in_bytes = unspents.count * 180
      
      # Add on 3 outputs of assumed size 50 bytes.
      size_in_bytes = size_in_bytes + (3 * 34)
      
      # Add on 50 bytes for good luck
      size_in_bytes += unspents.count
      
      size_in_bytes += 10
      
      return size_in_bytes
      
    end
    
    # Once a transaction is created we rip it aaprt again to make sure it is not
    # overspending the users funds.
    def interrogate_transaction(txhex, wallet_addresses, fee_addresses, 
      total_to_send, network = :bitcoin)
      
      if network == :ethereum
        return interrogate_transaction_ethereum(txhex, wallet_addresses)
      end
      
      return interrogate_transaction_bitcoin_and_forks(txhex, wallet_addresses, 
        fee_addresses, total_to_send, network)
    end
    
    # Pull apart the ERC20 transaction
    def interrogate_token(txhex, token_decimals)
      
      miners_fee = 0
      
      tx = Eth::Tx.decode txhex
      
      if tx.value != 0
        throw 'Token transaction is sending Ethereum.'
      end
      
      miners_fee = tx.gas_price * tx.gas_limit / 1_000000_000000_000000.0
      
      #total_to_send = tx.value / 1_000000_000000_000000.0
      data = tx.data_hex
      
      address = '0x' + data[34..73]
      
      amount_hex = data[74 .. data.length - 1]
      amount_hex.sub!(/^[0]+/,'')
      
      total_to_send = amount_hex.to_i(16)
      
      total_to_send = total_to_send / (10 ** token_decimals)
      
      return { miners_fee: miners_fee, total_change: 0,
        total_to_send: total_to_send, our_fees: 0,
        destination: address, unrecognised_destination: nil, 
        primary_send: total_to_send 
      }
    end
    
    def interrogate_transaction_ethereum(txhex, wallet_addresses)
      
      miners_fee = 0
      
      tx = Eth::Tx.decode txhex
      address = Eth::Utils.format_address(Eth::Utils.bin_to_hex(tx.to))
      
      miners_fee = tx.gas_price * tx.gas_limit / 1_000000_000000_000000.0
      
      total_to_send = tx.value / 1_000000_000000_000000.0
      
      return { miners_fee: miners_fee, total_change: 0,
        total_to_send: total_to_send, our_fees: 0,
        destination: address, unrecognised_destination: nil, 
        primary_send: total_to_send 
      }
    end
    
    # Once a transaction is created we rip it aaprt again to make sure it is not
    # overspending the users funds.
    def interrogate_transaction_bitcoin_and_forks(txhex, wallet_addresses, 
      fee_addresses, total_to_send, network = :bitcoin)
      
      tx_to_sign = Bitcoin::Protocol::Tx.create_from_hex(txhex, network)
      
      primary_send = 0
      our_fees = 0
      unrecognised_destination = 0
      total_change = 0
      miners_fee = 0
      address = ''
      
      tx_to_sign.out.each_with_index do |txout, index|
        
        dest = get_address_from_script(Bitcoin::Script.new(txout.script), network)
        
        if index == 0
          # The first out is the require destination
          address = dest
          primary_send += txout.value
        else
          # Other addresses are either chnage or fees.
          if fee_addresses.include? dest
            our_fees += txout.value
          elsif wallet_addresses.include? dest
            total_change += txout.value
          else
            unrecognised_destination += txout.value
          end
        end
        
      end
      
      miners_fee = total_to_send - our_fees - primary_send - total_change
      total_change = total_change / 100000000.0
      total_to_send = total_to_send / 100000000.0
      our_fees = our_fees / 100000000.0
      unrecognised_destination = unrecognised_destination / 100000000.0
      miners_fee = miners_fee / 100000000.0
      primary_send = primary_send / 100000000.0
      
      return { miners_fee: miners_fee, total_change: total_change,
        total_to_send: total_to_send, our_fees: our_fees,
        destination: address, unrecognised_destination: unrecognised_destination, 
        primary_send: primary_send 
      }
    
    end
    
    # Check a transactions inputs only spend enough to cover fees and amount
    # Basically if onchain creates an incorrect transaction the client
    # can identify it here.
    def check_integrity(txhex, amount, orig_addresses, dest_addr, tolerence)
      
      tx = Bitcoin::Protocol::Tx.create_from_hex(txhex)
      
      input_amount = 0
      # Let's add up the value of all the inputs.
      tx.in.each_with_index do |txin, index|
      
        prev_hash = txin.to_hash['prev_out']['hash']
        prev_index = txin.to_hash['prev_out']['n']
        
        # Get the amount for the previous output
        prevhex = OnChain::BlockChain.get_transaction(prev_hash)
        prev_tx = Bitcoin::Protocol::Tx.create_from_hex(prevhex)
        
        input_amount += prev_tx.out[prev_index].value
        
        if ! orig_addresses.include? prev_tx.out[prev_index].parsed_script.get_hash160_address
          raise "One of the inputs is not from from our list of valid originating addresses"
        end
      end
      
      # subtract the the chnage amounts
      tx.out.each do |txout|
        if orig_addresses.include? txout.parsed_script.get_address
          input_amount = input_amount - txout.value
        end
      end
      
      tolerence = (amount * (1 + tolerence)) 
      if input_amount > tolerence
        raise "Transaction has more input value (#{input_amount}) than the tolerence #{tolerence}"
      end
      
      return true
    end
    
    def create_transaction_from_public_keys(pub_keys, dest_addr, amount, 
      fee_in_satoshi, fee_addr, miners_fee, network = :bitcoin)
      
      orig_addresses = pub_keys.map { |key| pubhex_to_address(key, network) }
      
      txhex, inputs_to_sign, total_input_value = create_single_signature_transaction(
        orig_addresses, dest_addr, amount, 
        fee_in_satoshi, fee_addr, miners_fee, network)
      
      its = []
      pub_keys.each do |key| 
        addr = pubhex_to_address(key, :bitcoin)
        inputs_to_sign.each do |input|
          if input[addr] != nil
            its << { key => input[addr] }
          end
        end
      end
        
      return txhex, its, total_input_value
        
    end
    
    def pubhex_to_address(pub_hex, network)
    
      address_version = Bitcoin::NETWORKS[network][:address_version]
      
      address = Bitcoin.encode_address(Bitcoin.hash160(pub_hex), address_version)
      
      return address
    end
    
    def create_single_signature_transaction(orig_addresses, dest_addr, amount, 
      fee_in_satoshi, fee_addr, miners_fee, network = :bitcoin)

      tx = Bitcoin::Protocol::Tx.create_for_network(network)
      
      total_amount = amount + fee_in_satoshi + miners_fee
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(
        orig_addresses, total_amount, network)
      indexes = nil
      
      total_input_value = 0
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain.hex_to_bin(spent[2])
        total_input_value = total_input_value + spent[3].to_i
        tx.add_in(txin)
      end
      
      txout = Bitcoin::Protocol::TxOut.new(amount, to_address_script(dest_addr, network))
      tx.add_out(txout)
      
      # Add an output for the fee
      add_fee_to_tx(fee_in_satoshi, fee_addr, tx, network)
    
      # Send the change back. 546 is the dust price for bitcoin.
      if change > DUST_SATOSHIES
        
        txout = Bitcoin::Protocol::TxOut.new(change, 
          to_address_script(orig_addresses.first, network))
  
        tx.add_out(txout)
      end

      inputs_to_sign = tx.get_inputs_to_sign(unspents, network)
      
      return OnChain::bin_to_hex(tx.to_network_payload(network)), inputs_to_sign, total_input_value
    end
    
    def create_single_address_transaction(orig_addr, dest_addr, amount, 
      fee_in_satoshi, fee_addr, miners_fee, network = :bitcoin)

      return create_single_signature_transaction([orig_addr], dest_addr, 
        amount, fee_in_satoshi, fee_addr, miners_fee, network)
    end
    
    # Given a send address and an amount produce a transaction 
    # and a list of hashes that need to be signed.
    # 
    # The transaction will be in hex format.
    #
    # The list of hashes that need to be signed will be in this format
    #
    # [input index]{public_key => { :hash => hash} }
    #
    # i.e.
    #
    # [0][034000....][:hash => '345435345...'] 
    # [0][02fee.....][:hash => '122133445....']
    # 
    def create_transaction(redemption_scripts, address, amount_in_satoshi, 
      miners_fee, fee_in_satoshi, fee_addr, network = :bitcoin)
    
      total_amount = amount_in_satoshi + fee_in_satoshi + miners_fee
      
      addresses = redemption_scripts.map { |rs| 
        generate_address_of_redemption_script(rs, network)
      }
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(
        addresses, total_amount, network)
      
      # OK, let's build a transaction.
      tx = Bitcoin::Protocol::Tx.create_for_network(network)
      
      total_input_value = 0
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        script = redemption_scripts[indexes[index]]
        
        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain::hex_to_bin(script)
        total_input_value = total_input_value + spent[3].to_i
        tx.add_in(txin)
      end

      # Add an output for the main transfer
      txout = Bitcoin::Protocol::TxOut.new(amount_in_satoshi, 
          to_address_script(address, network))
      tx.add_out(txout)
      
      # Add an output for the fee
      add_fee_to_tx(fee_in_satoshi, fee_addr, tx, network)
      
      change_address = addresses[0]
    
      # Send the change back.
      if change > 0
      
        txout = Bitcoin::Protocol::TxOut.new(change, 
          to_address_script(change_address, network))
  
        tx.add_out(txout)
      end

      inputs_to_sign = tx.get_inputs_to_sign(unspents, network)
    
      return OnChain::bin_to_hex(tx.to_network_payload(network)), inputs_to_sign, total_input_value
    end
  
    # Given a transaction in hex string format, apply
    # the given signature list to it.
    #
    # Signatures should be in the format
    #
    # [0]{034000.....' => {'hash' => '345435345....', 'sig' => '435fgdf4553...'}}
    # [1]{02fee.....' => {'hash' => '122133445....', 'sig' => '435fgdf4553...'}}
    #
    def sign_single_signature_transaction(transaction_hex, sig_list, 
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all],
      network = :bitcoin)
      
      tx = Bitcoin::Protocol::Tx.create_from_hex(transaction_hex, network)
      
      tx.in.each_with_index do |txin, index|
        
        public_key_hex = sig_list[index].keys.first
        
        sig = sig_list[index][public_key_hex]['sig']
        
        txin.script = Bitcoin::Script.to_pubkey_script_sig(
          OnChain.hex_to_bin(sig), 
          OnChain.hex_to_bin(public_key_hex), hash_type)
      end
      
      return OnChain::bin_to_hex(tx.to_network_payload(network))
    end
     
  
    # Given a transaction in hex string format, apply
    # the given signature list to it.
    #
    # Signatures should be in the format
    #
    # [0]{034000.....' => {'hash' => '345435345....', 'sig' => '435fgdf4553...'}}
    # [0]{02fee.....' => {'hash' => '122133445....', 'sig' => '435fgdf4553...'}}
    #
    # For transactions coming from non multi sig wallets we need to set
    # the pubkey parameter to the full public hex key of the address.
    def sign_transaction(transaction_hex, sig_list, pubkey = nil, 
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all],
      network = :bitcoin)
      
      tx = Bitcoin::Protocol::Tx.create_from_hex(transaction_hex, network)
      
      tx.in.each_with_index do |txin, index|
        
        sigs = []
        
        rscript = Bitcoin::Script.new txin.script
        
        pub_keys = Bitcoin::Protocol::Tx.get_public_keys_from_script(rscript)
        pub_keys.each do |hkey|
          
          if sig_list[index][hkey] != nil and sig_list[index][hkey]['sig'] != nil
            
            # Add the signature to the list.
            sigs << OnChain.hex_to_bin(sig_list[index][hkey]['sig'])
            
          end
        end
        
        if sigs.count > 0
          in_script = Bitcoin::Script.new txin.script
          if in_script.is_hash160?
            sig = sigs[0]
            txin.script = Bitcoin::Script.to_pubkey_script_sig(sig, 
              OnChain.hex_to_bin(pubkey), hash_type)
          else
            
            # I replace the call to Bitcoin::Script.to_p2sh_multisig_script_sig
            # as it didn't work for my smaller 2 of 2 redemption scripts
            sig_script = '00'
            sigs.each do |sigg|
              sigg << hash_type
              sig_script += sigg.length.to_s(16)
              sig_script += OnChain.bin_to_hex(sigg)
            end
            if rscript.to_payload.length < 76
              sig_script += rscript.to_payload.length.to_s(16)
              sig_script += OnChain.bin_to_hex(rscript.to_payload)
            else
              sig_script += 76.to_s(16)
              sig_script += rscript.to_payload.length.to_s(16)
              sig_script += OnChain.bin_to_hex(rscript.to_payload)
            end
              
            txin.script = OnChain.hex_to_bin(sig_script)
          end
        end
      
        #raise "Signature error " + index.to_s  if ! tx.verify_input_signature(index, in_script.to_payload)
      end
      
      return OnChain::bin_to_hex(tx.to_network_payload(network))
    end
    
    # Run through the signature list and check it is all signed.
    def do_we_have_all_the_signatures(sig_list)
      
      sig_list.each do |input|
        input.each_key do |public_key|
          if input[public_key]['hash'] == nil or input[public_key]['sig'] == nil
            return false
          end
        end
      end
      
      return true
    end
    
    private
    
    def add_fee_to_tx(fee, fee_addr, tx, network = :bitcoin)
      
      # Add wallet fee
      if fee > 0 
        
        # Check for affiliate
        if fee_addr.kind_of?(Array)
          affil_fee = fee / 2
          txout1 = Bitcoin::Protocol::TxOut.new(affil_fee, 
            to_address_script(fee_addr[0], network))
          txout2 = Bitcoin::Protocol::TxOut.new(affil_fee, 
            to_address_script(fee_addr[1], network))
          tx.add_out(txout1)
          tx.add_out(txout2)
        else
          txout = Bitcoin::Protocol::TxOut.new(fee, 
            to_address_script(fee_addr, network))
          tx.add_out(txout)
        end
      end
      
    end
    
    # This runs when we are decoding a transaction
    def get_address_from_script(script, network)
      
      if script.is_p2sh?
        p2sh_version = Bitcoin::NETWORKS[network][:p2sh_version]
        return Bitcoin.encode_address script.get_hash160, p2sh_version
      else
        address_version = Bitcoin::NETWORKS[network][:address_version]
        return Bitcoin.encode_address(script.get_hash160, address_version)
      end
    end
  
    def generate_address_of_redemption_script(script, network = :bitcoin)
      
      p2sh_version = Bitcoin::NETWORKS[network][:p2sh_version]
      address = Bitcoin.encode_address(Bitcoin.hash160(script), p2sh_version)
      
      return address
    end
  
    # This was created as the method in bitcoin ruby was not network aware.
    def to_address_script(address, network_to_use = :bitcoin)
      
      size = Bitcoin::NETWORKS[network_to_use][:p2sh_version].length
      
      address_type = :hash160
      if Bitcoin.decode_base58(address)[0...size] == Bitcoin::NETWORKS[network_to_use][:p2sh_version].downcase
        address_type = :p2sh
      end
      
      hash160 = Bitcoin.decode_base58(address)[size...(40 + size)]
      
      case address_type
      when :hash160; Bitcoin::Script.to_hash160_script(hash160)
      when :p2sh;    Bitcoin::Script.to_p2sh_script(hash160)
      end
    end
    
  end
end
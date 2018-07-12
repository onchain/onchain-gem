class OnChain::Transaction
  class << self
    
    DUST_SATOSHIES = 548
    MINERS_BYTE_FEE = 100
    CACHE_KEY = 'Bitcoin21Fees'
    CACHE_FOR = 10 # 10 minutes, roughly each block.
    
    # Zcash
    ZCASH_PREVOUTS_HASH_PERSONALIZATION   = 'ZcashPrevoutHash'
    ZCASH_SEQUENCE_HASH_PERSONALIZATION   = 'ZcashSequencHash'
    ZCASH_OUTPUTS_HASH_PERSONALIZATION    = 'ZcashOutputsHash'
    ZCASH_JOINSPLITS_HASH_PERSONALIZATION = 'ZcashJSplitsHash'
    ZCASH_SIG_HASH_PERSONALIZATION        = 'ZcashSigHash'
      
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
      
      tx_bin = txhex.scan(/../).map { |x| x.hex }.pack('c*')
      tx_to_sign = Bitcoin::Protocol::Tx.new(tx_bin)
      
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
      
      tx = Bitcoin::Protocol::Tx.new OnChain::hex_to_bin(txhex)
      
      input_amount = 0
      # Let's add up the value of all the inputs.
      tx.in.each_with_index do |txin, index|
      
        prev_hash = txin.to_hash['prev_out']['hash']
        prev_index = txin.to_hash['prev_out']['n']
        
        # Get the amount for the previous output
        prevhex = OnChain::BlockChain.get_transaction(prev_hash)
        prev_tx = Bitcoin::Protocol::Tx.new OnChain::hex_to_bin(prevhex)
        
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

      tx = Bitcoin::Protocol::Tx.new
      tx.ver = 3 if network == :zcash
      
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

      inputs_to_sign = get_inputs_to_sign(tx, unspents, network)
      
      return OnChain::bin_to_hex(tx.to_payload), inputs_to_sign, total_input_value
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
      tx = Bitcoin::Protocol::Tx.new
      
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

      inputs_to_sign = get_inputs_to_sign(tx, unspents, network)
    
      return OnChain::bin_to_hex(tx.to_payload), inputs_to_sign, total_input_value
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
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all])
      
      tx = Bitcoin::Protocol::Tx.new OnChain::hex_to_bin(transaction_hex)
      
      tx.in.each_with_index do |txin, index|
        
        public_key_hex = sig_list[index].keys.first
        
        sig = sig_list[index][public_key_hex]['sig']
        
        txin.script = Bitcoin::Script.to_pubkey_script_sig(
          OnChain.hex_to_bin(sig), 
          OnChain.hex_to_bin(public_key_hex), hash_type)
      end
      
      return OnChain::bin_to_hex(tx.to_payload)
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
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all])
      
      tx = Bitcoin::Protocol::Tx.new OnChain::hex_to_bin(transaction_hex)
      
      tx.in.each_with_index do |txin, index|
        
        sigs = []
        
        rscript = Bitcoin::Script.new txin.script
        
        pub_keys = get_public_keys_from_script(rscript)
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
      
      return OnChain::bin_to_hex(tx.to_payload)
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
    
    def get_public_keys_from_script(script)
  
      if script.is_hash160?
        return [Bitcoin.hash160_to_address(script.get_hash160)]
      end
      
      pubs = []
      script.get_multisig_pubkeys.each do |pub|
        pubs << OnChain.bin_to_hex(pub)
      end
      return pubs
    end
    
    def get_inputs_to_sign(tx, unspents, network = :bitcoin)
      inputs_to_sign = []
      tx.in.each_with_index do |txin, index|


        if network == :zcash

          # ZCash
          script_code = Bitcoin::Protocol.pack_var_string(txin.script)
          sig_hash =  Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all] 
          hash = signature_hash_for_zcash(tx, index, txin.script, 
            unspents[index][3], sig_hash)

        elsif Bitcoin::NETWORKS[network][:fork_id] == nil

          # The Bitcoin and statndard forks implement the hash
          hash = tx.signature_hash_for_input(index, txin.script, 
            Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all])
        elsif network == :bitcoin_private

          # Bitcoin private
          sig_hash = Bitcoin::Protocol::Tx::SIGHASH_TYPE[:forkid] | 
            Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all] 
          hash = signature_hash_for_bitcoin_private_input(tx, index, txin.script, 
            sig_hash, Bitcoin::NETWORKS[network][:fork_id])

        else
          # Replay protection as used by bitcoin cash and bitcoin gold

          sig_hash = Bitcoin::Protocol::Tx::SIGHASH_TYPE[:forkid] | 
            Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all] 
        
          # This is not implemented in bitcoin ruby 
          # see https://github.com/lian/bitcoin-ruby/blob/05eae36cf04b0dd426930dbea34d48769272f9d2/lib/bitcoin/protocol/tx.rb#L188
          #hash = tx.signature_hash_for_input(index, txin.script, 
          #  sig_hash, unspents[index][3], Bitcoin::NETWORKS[network][:fork_id])
          
          script_code = Bitcoin::Protocol.pack_var_string(txin.script)
          hash = signature_hash_with_a_fork_id(tx, index, script_code, 
            unspents[index][3], sig_hash, Bitcoin::NETWORKS[network][:fork_id])
        end
        
        script = Bitcoin::Script.new txin.script
        
        pubkeys = get_public_keys_from_script(script)
        pubkeys.each do |key|
          
          if inputs_to_sign[index] == nil
            inputs_to_sign[index] = {}
          end
          inputs_to_sign[index][key] = {'hash' => OnChain::bin_to_hex(hash)}
        end
      end
      return inputs_to_sign
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
    
    private
    
    # ZCash over winter.
    #
    # https://github.com/zcash/zips/blob/master/zip-0143.rst
    #
    def signature_hash_for_zcash(tx, input_idx, 
      script_code, prev_out_value, hash_type)
     
      prev_outs_bin = tx.in.map{|i| [i.prev_out_hash, i.prev_out_index].pack("a32V")}.join
      blake_hex = OnChain.blake2b(OnChain::bin_to_hex(prev_outs_bin), ZCASH_PREVOUTS_HASH_PERSONALIZATION)
      hash_prevouts = OnChain::hex_to_bin(blake_hex)
      
      sequence_bin = tx.in.map{|i|i.sequence}.join
      blake_hex = OnChain.blake2b(OnChain::bin_to_hex(sequence_bin), ZCASH_SEQUENCE_HASH_PERSONALIZATION)
      hash_sequence = OnChain::hex_to_bin(blake_hex)
        
      outpoint = [tx.in[input_idx].prev_out_hash, 
        tx.in[input_idx].prev_out_index].pack("a32V")
        
      amount = [prev_out_value].pack("Q")
      
      nsequence = tx.in[input_idx].sequence
      
      outputs_bin = tx.out.map{|o|o.to_payload}.join
      blake_hex = OnChain.blake2b(OnChain::bin_to_hex(outputs_bin), ZCASH_OUTPUTS_HASH_PERSONALIZATION)
      hash_outputs = OnChain::hex_to_bin(blake_hex)
        
      hash_joins        = OnChain::hex_to_bin("0" * 64)
      hash_type         = [hash_type].pack("V")
      lock_time         = [tx.lock_time].pack("V")
      expiry_height     = [0].pack("V")
      version           = [tx.ver | 0x80000000].pack("V")
      version_group_id  = [0x03c48270].pack("V")

      buf = [ 
        version,                                  # 1. nVersion | fOverwintered
        version_group_id,                         # 2. nVersionGroupId
        hash_prevouts,                            # 3. hashPrevouts
        hash_sequence,                            # 4. hashSequence
        hash_outputs,                             # 5. hashOutputs
        hash_joins,                               # 6. hashJoinSplits
        lock_time,                                # 7. nLockTime
        expiry_height,                            # 8. expiryHeight
        hash_type,                                # 9. nHashType
        outpoint,                                 # 10a. outpoint
        script_code,                              # 10b. scriptCode
        amount,                                   # 10c. value
        nsequence                                 # 10d. nSequence
      ].join
      
      
      #puts OnChain::bin_to_hex(version) + "\t\t\t\t\t\t\t\t\t# 1. nVersion | fOverwintered"
      #puts OnChain::bin_to_hex(version_group_id) + "\t\t\t\t\t\t\t\t\t# 2. nVersionGroupId"
      #puts OnChain::bin_to_hex(hash_prevouts) + "\t\t# 3. hashPrevouts"
      #puts OnChain::bin_to_hex(hash_sequence) + "\t\t# 4. hashSequence"
      #puts OnChain::bin_to_hex(hash_outputs) + "\t\t# 5. hash_outputs"
      #puts OnChain::bin_to_hex(hash_joins) + "\t\t# 6. hashJoinSplits"
      #puts OnChain::bin_to_hex(lock_time) + "\t\t\t\t\t\t\t\t\t# 7. nLockTime"
      #puts OnChain::bin_to_hex(hash_type) + "\t\t\t\t\t\t\t\t\t# 9. nHashType"
      #puts OnChain::bin_to_hex(outpoint) + "\t# 10a. outpoint"
      #puts OnChain::bin_to_hex(script_code) + "\t\t\t\t# 10b. scriptCode"
      #puts OnChain::bin_to_hex(amount) + "\t\t\t\t\t\t\t\t# 10c. value"
      #puts OnChain::bin_to_hex(nsequence) + "\t\t\t\t\t\t\t\t\t# 10d. nSequence"

      blake_hex = OnChain.blake2b(OnChain::bin_to_hex(buf), ZCASH_SIG_HASH_PERSONALIZATION)
      
      return OnChain::hex_to_bin(blake_hex)
    end
    
    # Used by bitocin cash with a fork_id of zero.
    #
    # Bitcoin Private has a fork id of 42 and Gold 79.
    #
    # Electrum code for Gold. https://github.com/BTCGPU/electrum/blob/master/lib/transaction.py#L849
    #
    # Elecrum code for Bitocin Private https://github.com/BTCPrivate/electrum-btcp/blob/712117fece1a0028c7f5192c0448ab7cc85e9c3c/lib/transaction.py#L764
    #
    def signature_hash_with_a_fork_id(tx, input_idx, 
      script_code, prev_out_value, hash_type, fork_id)
     
      hash_prevouts = Digest::SHA256.digest(Digest::SHA256.digest(
        tx.in.map{|i| [i.prev_out_hash, i.prev_out_index].pack("a32V")}.join))
        
      hash_sequence = Digest::SHA256.digest(Digest::SHA256.digest(
        tx.in.map{|i|i.sequence}.join))
        
      outpoint = [tx.in[input_idx].prev_out_hash, 
        tx.in[input_idx].prev_out_index].pack("a32V")
        
      amount = [prev_out_value].pack("Q")
      
      nsequence = tx.in[input_idx].sequence
      
      hash_outputs = Digest::SHA256.digest(Digest::SHA256.digest(
        tx.out.map{|o|o.to_payload}.join))
      
      hash_type |= fork_id << 8

      buf = [ [tx.ver].pack("V"), hash_prevouts, hash_sequence, outpoint,
              script_code, amount, nsequence, hash_outputs, 
              [tx.lock_time, hash_type].pack("VV")].join

      Digest::SHA256.digest( Digest::SHA256.digest( buf ) )
    end


    # Bitcoin Private way of hashing inputs for signing
    def signature_hash_for_bitcoin_private_input(tx, input_idx, subscript, 
      hash_type, fork_id)
      # https://github.com/BTCPrivate/BitcoinPrivate/blob/master/src/script/interpreter.cpp#L1102
      # https://github.com/BTCGPU/BTCGPU/blob/master/src/script/interpreter.cpp#L1212
      # https://github.com/BTCPrivate/BitcoinPrivate/blob/master/src/script/interpreter.cpp#L1047

      hash_type ||= SIGHASH_TYPE[:all]
      
      # This is what we useds to do.
      #pin  = tx.in.map.with_index{|input,idx|
      #  subscript = subscript.out[ input.prev_out_index ].script if 
      #    subscript.respond_to?(:out) # legacy api (outpoint_tx)
      #
      #  # Remove all instances of OP_CODESEPARATOR from the script.
      #  parsed_subscript = Bitcoin::Script.new(subscript)
      #  parsed_subscript.chunks.delete(Bitcoin::Script::OP_CODESEPARATOR)
      #  subscript = parsed_subscript.to_binary
      #
      #  input.to_payload(subscript)
      #}

      #for (unsigned int nInput = 0; nInput < nInputs; nInput++)
      #       SerializeInput(s, nInput, nType, nVersion);
      pin  = tx.in.map.with_index{|input,idx|
        if idx == input_idx
          subscript = subscript.out[ input.prev_out_index ].script if subscript.respond_to?(:out) # legacy api (outpoint_tx)

          # Remove all instances of OP_CODESEPARATOR from the script.
          parsed_subscript = Bitcoin::Script.new(subscript)
          parsed_subscript.chunks.delete(Bitcoin::Script::OP_CODESEPARATOR)
          subscript = parsed_subscript.to_binary

          input.to_payload(subscript)
        else
          case (hash_type & 0x1f)
          when Bitcoin::Script::SIGHASH_TYPE[:none];   input.to_payload("", "\x00\x00\x00\x00")
          when Bitcoin::Script::SIGHASH_TYPE[:single]; input.to_payload("", "\x00\x00\x00\x00")
          else;                       input.to_payload("")
          end
        end
      }

      #for (unsigned int nOutput = 0; nOutput < nOutputs; nOutput++)
      #       SerializeOutput(s, nOutput, nType, nVersion);
      pout = tx.out.map(&:to_payload)
      
      in_size = Bitcoin::Protocol.pack_var_int(tx.in.size)
      out_size = Bitcoin::Protocol.pack_var_int(tx.out.size)

      fork_hash_type = hash_type
      fork_hash_type |= fork_id << 8

      buf = [ [tx.ver].pack("V"),       # ::Serialize(s, txTo.nVersion, nType, nVersion);
        in_size,                        # unsigned int nInputs = fAnyoneCanPay ? 1 : txTo.vin.size();
        pin, 
        out_size,                       # unsigned int nOutputs = fHashNone ? 0 : (fHashSingle ? nIn+1 : txTo.vout.size());
        pout, 
        [tx.lock_time].pack("V"),
        [fork_hash_type].pack("V") 
      ].join

      Digest::SHA256.digest( Digest::SHA256.digest( buf ) )
    end
  end
end
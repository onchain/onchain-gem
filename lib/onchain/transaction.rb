class OnChain::Transaction
  class << self
    
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
    
    def create_single_address_transaction(orig_addr, dest_addr, amount, 
      fee_percent, fee_addr, miners_fee, network = :bitcoin)

      tx = Bitcoin::Protocol::Tx.new
      
      fee = calculate_fee(amount, fee_percent, miners_fee)
  
      total_amount = amount + fee
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(
        [orig_addr], total_amount, network)
      indexes = nil
    
      
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain.hex_to_bin(spent[2])
        tx.add_in(txin)
      end
      txout = Bitcoin::Protocol::TxOut.new(amount, to_address_script(dest_addr, network))
  
      tx.add_out(txout)
      
      # Add wallet fee
      add_fee_to_tx(fee, fee_addr, tx, miners_fee, network)
    
      # Send the change back.
      if change > 0
        
        txout = Bitcoin::Protocol::TxOut.new(change, to_address_script(orig_addr, network))
  
        tx.add_out(txout)
      end

      inputs_to_sign = get_inputs_to_sign(tx)
      
      return OnChain::bin_to_hex(tx.to_payload), inputs_to_sign
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
      miners_fee, fee_percent, fee_addr, network = :bitcoin)
    
      fee = calculate_fee(amount_in_satoshi, fee_percent, miners_fee)
  
      total_amount = amount_in_satoshi + fee
      
      addresses = redemption_scripts.map { |rs| 
        generate_address_of_redemption_script(rs, network)
      }
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(addresses, total_amount, network)
      
      # OK, let's build a transaction.
      tx = Bitcoin::Protocol::Tx.new
      
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        script = redemption_scripts[indexes[index]]
        
        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain::hex_to_bin(script)
        tx.add_in(txin)
      end
      
      # Add wallet fee
      add_fee_to_tx(fee, fee_addr, tx, miners_fee)
      
      # Do we have enough in the fund.
      #if(total_amount > btc_balance)
      #  raise 'Balance is not enough to cover payment'
      #end

      txout = Bitcoin::Protocol::TxOut.new(amount_in_satoshi, 
          to_address_script(address, network))
  
      tx.add_out(txout)
      
      change_address = addresses[0]
    
      # Send the change back.
      if change > 0
      
        txout = Bitcoin::Protocol::TxOut.new(change, 
          to_address_script(change_address, network))
  
        tx.add_out(txout)
      end

      inputs_to_sign = get_inputs_to_sign tx
    
      return OnChain::bin_to_hex(tx.to_payload), inputs_to_sign
    end
  
    # Given a transaction in hex string format, apply
    # the given signature list to it.
    #
    # Signatures should be in the format
    #
    # [0]{034000.....' => {'hash' => '345435345....', 'sig' => '435fgdf4553...'}}
    # [0]{02fee.....' => {'hash' => '122133445....', 'sig' => '435fgdf4553...'}}
    #
    def sign_transaction(transaction_hex, sig_list)
      
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
            txin.script = Bitcoin::Script.to_pubkey_script_sig(sig, OnChain.hex_to_bin(pubkey))
          else
            
            # I replace the call to Bitcoin::Script.to_p2sh_multisig_script_sig
            # as it didn't work for my smaller 2 of 2 redemption scripts
            sig_script = '00'
            sigs.each do |sigg|
              sigg << 1
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
    
    def add_fee_to_tx(fee, fee_addr, tx, miners_fee, network = :bitcoin)
      
      # Add wallet fee
      if fee > 0 and (fee - miners_fee) > 0
        
        # Take the miners fee from the wallet fees
        fee = fee - miners_fee
        
        # Check for affiliate
        if fee_addr.kind_of?(Array)
          affil_fee = fee / 2
          txout1 = Bitcoin::Protocol::TxOut.new(affil_fee, to_address_script(fee_addr[0], network))
          txout2 = Bitcoin::Protocol::TxOut.new(affil_fee, to_address_script(fee_addr[1], network))
          tx.add_out(txout1)
          tx.add_out(txout2)
        else
          txout = Bitcoin::Protocol::TxOut.new(fee, to_address_script(fee_addr, network))
          tx.add_out(txout)
        end
      end
      
    end
    
    def calculate_fee(amount, fee_percent, min_fee_satoshi)
      
      fee = (amount * (fee_percent / 100.0)).to_i
      
      if fee < min_fee_satoshi
        return min_fee_satoshi
      end
      
      return fee
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
    
    def get_inputs_to_sign(tx)
      inputs_to_sign = []
      tx.in.each_with_index do |txin, index|
        hash = tx.signature_hash_for_input(index, txin.script, 1)
        
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
      
  end
end
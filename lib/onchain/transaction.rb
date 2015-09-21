class OnChain::Transaction
  class << self
    
    def create_single_address_transaction(orig_addr, dest_addr, amount, fee_percent, fee_addr, min_fee_satoshi)

      tx = Bitcoin::Protocol::Tx.new
      
      fee = calculate_fee(amount, fee_percent, min_fee_satoshi)
  
      total_amount = amount + fee
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(
        [orig_addr], total_amount)
    
      
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain.hex_to_bin(spent[2])
        tx.add_in(txin)
      end
      txout = Bitcoin::Protocol::TxOut.new(amount, Bitcoin::Script.to_address_script(dest_addr))
  
      tx.add_out(txout)
      
      # Add wallet fee
      add_fee_to_tx(fee, fee_addr, tx)
    
      # Send the change back.
      if change > 0
        
        txout = Bitcoin::Protocol::TxOut.new(change, Bitcoin::Script.to_address_script(orig_addr))
  
        tx.add_out(txout)
      end

      inputs_to_sign = get_inputs_to_sign(tx)
      
      return OnChain::bin_to_hex(tx.to_payload), inputs_to_sign
    end
    
    def add_fee_to_tx(fee, fee_addr, tx)
      
      # Add wallet fee
      if fee > 0 and (fee - 10000) > 0
        
        # Take the miners fee from the wallet fees
        fee = fee - 10000
        
        # Check for affiliate
        if fee_addr.kind_of?(Array)
          affil_fee = fee / 2
          txout1 = Bitcoin::Protocol::TxOut.new(affil_fee, Bitcoin::Script.to_address_script(fee_addr[0]))
          txout2 = Bitcoin::Protocol::TxOut.new(affil_fee, Bitcoin::Script.to_address_script(fee_addr[1]))
          tx.add_out(txout1)
          tx.add_out(txout2)
        else
          txout = Bitcoin::Protocol::TxOut.new(fee, Bitcoin::Script.to_address_script(fee_addr))
          tx.add_out(txout)
        end
      end
      
    end
    
    # Like create_single_address_transaction but for multi sig wallets.
    def create_transaction_with_fee(redemption_scripts, address, amount, fee_percent, fee_addr)
    
      fee = calculate_fee(amount, fee_percent)
  
      total_amount = amount + fee
      
      addresses = redemption_scripts.map { |rs| 
        OnChain::Sweeper.generate_address_of_redemption_script(rs)
      }
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(addresses, total_amount)
      
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
      add_fee_to_tx(fee, fee_addr, tx)

      txout = Bitcoin::Protocol::TxOut.new(amount, Bitcoin::Script.to_address_script(address))
  
      tx.add_out(txout)
      
      change_address = addresses[0]
    
      # Send the change back.
      if change > 0
      
        txout = Bitcoin::Protocol::TxOut.new(change, 
          Bitcoin::Script.to_address_script(change_address))
  
        tx.add_out(txout)
      end

      inputs_to_sign = get_inputs_to_sign tx
    
      return OnChain::bin_to_hex(tx.to_payload), inputs_to_sign
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
        pub_hex = OnChain.bin_to_hex(pub)
        pubs << Bitcoin.hash160_to_address(Bitcoin.hash160(pub_hex))
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
    def create_transaction(redemption_scripts, address, amount_in_satoshi, miners_fee)
    
      total_amount = miners_fee
  
      total_amount = total_amount + amount_in_satoshi
      
      addresses = redemption_scripts.map { |rs| 
        OnChain::Sweeper.generate_address_of_redemption_script(rs)
      }
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(addresses, total_amount)
      
      # OK, let's build a transaction.
      tx = Bitcoin::Protocol::Tx.new
      
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        script = redemption_scripts[indexes[index]]
        
        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain::hex_to_bin(script)
        tx.add_in(txin)
      end
      
      # Do we have enough in the fund.
      #if(total_amount > btc_balance)
      #  raise 'Balance is not enough to cover payment'
      #end

      txout = Bitcoin::Protocol::TxOut.new(amount_in_satoshi, 
          Bitcoin::Script.to_address_script(address))
  
      tx.add_out(txout)
      
      change_address = addresses[0]
    
      # Send the change back.
      if change > 0
      
        txout = Bitcoin::Protocol::TxOut.new(change, 
          Bitcoin::Script.to_address_script(change_address))
  
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
    def sign_transaction(transaction_hex, sig_list, pubkey = nil)
      
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
            txin.script = Bitcoin::Script.to_p2sh_multisig_script_sig(rscript.to_payload, sigs)
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
    
  end
end
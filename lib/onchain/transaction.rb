class OnChain::Transaction
  class << self
    
    def create_single_address_transaction(orig_addr, dest_addr, amount, fee_percent, fee_addr)
    
      tx = Bitcoin::Protocol::Tx.new
  
      total_amount = amount + calculate_fee(amount, fee_percent)
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(
        [orig_addr], total_amount)
    
      
      # Process the unpsent outs.
      unspents.each_with_index do |spent, index|

        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = Bitcoin::Script.to_pubkey_script(orig_addr)
        tx.add_in(txin)
      end

      txout = Bitcoin::Protocol::TxOut.new(amount, Bitcoin::Script.to_address_script(dest_addr))
  
      tx.add_out(txout)
    
      # Send the change back.
      if change > 0
      
        txout = Bitcoin::Protocol::TxOut.new(change, 
          Bitcoin::Script.to_address_script(orig_addr))
  
        tx.add_out(txout)
      end
      
      return OnChain::bin_to_hex(tx.to_payload)
    end
    
    def calculate_fee(amount, fee_percent)
      
      fee = (amount * (fee_percent / 100.0)).to_i
      
      if fee < 10000
        return 0
      end
      
      return fee
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

      inputs_to_sign = []
      tx.in.each_with_index do |txin, index|
        hash = tx.signature_hash_for_input(index, txin.script, 1)
        
        rsscript = Bitcoin::Script.new txin.script
        rsscript.get_multisig_pubkeys.each do |key|
          
          if inputs_to_sign[index] == nil
            inputs_to_sign[index] = {}
          end
          inputs_to_sign[index][OnChain.bin_to_hex(key)] = {'hash' => OnChain::bin_to_hex(hash)}
        end
      end
    
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
        
        hash = OnChain.bin_to_hex(tx.signature_hash_for_input(index, txin.script, 1))
        
        sigs = []
        
        rscript = Bitcoin::Script.new txin.script
        rscript.get_multisig_pubkeys.each do |key|
          
          hkey = OnChain.bin_to_hex(key)
          if sig_list[index][hkey] != nil and sig_list[index][hkey]['sig'] != nil
            
            # Add the signature to the list.
            sigs << OnChain.hex_to_bin(sig_list[index][hkey]['sig'])
            
          end
        end
        
        if sigs.count > 0
          txin.script = Bitcoin::Script.to_p2sh_multisig_script_sig(rscript.to_payload, sigs)
        end
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
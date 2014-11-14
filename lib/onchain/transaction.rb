class OnChain::Transaction
  class << self
    
    def create_transaction(redemption_scripts, address, amount_in_satoshi, miners_fee)
    
      tx = Bitcoin::Protocol::Tx.new
  
      total_amount = miners_fee
  
      total_amount = total_amount + amount_in_satoshi
      
      addresses = redemption_scripts.map { |rs| 
        OnChain::Sweeper.generate_address_of_redemption_script(rs)
      }
      
      unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(addresses, total_amount)
      
      # OK, let's build a transaction.
      tx = Bitcoin::Protocol::Tx.new
      
      # Process the unpsent outs.
      meta_data = {}
      unspents.each_with_index do |spent, index|

        script = redemption_scripts[indexes[index]]
        
        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain::hex_to_bin(script)
        tx.add_in(txin)
        
        meta_data['m/' + indexes[index].to_s] = true
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
        
      meta = meta_data.keys.join(",")
    
      return OnChain::bin_to_hex(tx.to_payload), meta
    end
    
    def signTransaction(tx, pubkeys, sigs)
    end
    
    private
    
    def get_public_keys_from_redemption_script
    end
  end
end
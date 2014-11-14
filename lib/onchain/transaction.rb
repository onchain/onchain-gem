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
      hashes = []
      unspents.each_with_index do |spent, index|

        script = redemption_scripts[indexes[index]]
        
        txin = Bitcoin::Protocol::TxIn.new([ spent[0] ].pack('H*').reverse, spent[1])
        txin.script_sig = OnChain::hex_to_bin(script)
        tx.add_in(txin)
        
        hash = tx.signature_hash_for_input(tx.in.count - 1, OnChain::hex_to_bin(script), 1)
        
        rs_script = Bitcoin::Script.new OnChain::hex_to_bin(script)
        rs_script.get_multisig_pubkeys.each do |key|
          hashes << OnChain.bin_to_hex(key) +  ':' + OnChain::bin_to_hex(hash)
        end
        
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
    
      return OnChain::bin_to_hex(tx.to_payload), hashes
    end
    
    def signTransaction(tx, pubkeys, sigs)
    end
    
    private
    
    def get_public_keys_from_redemption_script
    end
  end
end
class OnChain::Sweeper
  class << self
    
    def multi_sig_node_for_path(redemption_script)
      
      rs = OnChain::Payments.hex_to_script(redemption_script)
      
      puts rs
      
      puts rs.get_multisig_pubkeys
      # 1. get the public keys from the script
      # 2. create hd wallet for each key
      # 3. navigate down to path
      # 4. Recreate redemption script and address
    end
    
    # With a bunch of HD wallet paths, build a transaction
    # That pays all the coins to a certain address
    def sweep(paths, mpk, destination_address)
      
      master = MoneyTree::Node.from_serialized_address(mpk)
      
      tx = Bitcoin::Protocol::Tx.new
      
      amount = 0
      
      paths.each do |path|
      
        address = master.node_for_path(path).to_address
      
        unspent = OnChain::BlockChain.get_unspent_outs(address)
      
        unspent.each do |spent|
          txin = Bitcoin::Protocol::TxIn.new

          txin.prev_out = spent[0]
          txin.prev_out_index = spent[1]
          amount += spent[3].to_i
        
          tx.add_in(txin)
        end
      end

      txout = Bitcoin::Protocol::TxOut.new(amount, Bitcoin::Script.from_string(
        "OP_DUP OP_HASH160 #{destination_address} " + 
        "OP_EQUALVERIFY OP_CHECKSIG").to_payload)
      
      tx.add_out(txout)
    end
    
  end
end

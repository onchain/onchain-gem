class OnChain
  class << self
    
    
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

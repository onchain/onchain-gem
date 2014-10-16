class OnChain::Sweeper
  class << self
    
    # Turn a bunch of master keys into a redemption scriopt
    # i.e. derive the path.
    def multi_sig_address_from_mpks(mpks, path)
      
      addresses = []
      mpks.each do |mpk|
        master = MoneyTree::Node.from_serialized_address(mpk)
        m = master.node_for_path(path)
        addresses << m.public_key.to_hex
      end
      
      rs = generate_redemption_script(addresses)
      
      return generate_address_of_redemption_script(rs)
    end

    def generate_redemption_script(addresses)
    
      rs = (80 + addresses.length).to_s(16) 
    
      addresses.each do |address|
        rs = rs + (address.length / 2).to_s(16)
        rs = rs + address
      end
    
      rs = rs + (80 + addresses.length).to_s(16) 
    
      rs = rs + 'ae'
    
      return rs
    end
  
    def generate_address_of_redemption_script(redemption_script)
      hash160 = Bitcoin.hash160(redemption_script)
    
      return Bitcoin.hash160_to_p2sh_address(hash160)
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

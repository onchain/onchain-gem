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
    def sweep(mpks, path, limit, last_block_checked)
      
      for i in 0..limit do
        r = path.sub('#{index}', i.to_s)
        a = multi_sig_address_from_mpks(mpks, r)
        puts a
      end
      
    end
    
  end
end

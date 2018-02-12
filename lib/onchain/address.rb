class OnChain::Address
  class << self
    
    def generate_address_pair(network = :bitcoin)
      
      key = Bitcoin::Key.generate(network)
      
      version = Bitcoin::NETWORKS[network][:address_version]
      address = Bitcoin::encode_address(key.hash160, version)
        
      key = Bitcoin::Key.generate(network)
      return address, key.priv
    end
    
    def valid_address?(address, network = :bitcoin)
      
      hex = Bitcoin.decode_base58(address) rescue nil
      
      check =  Bitcoin.checksum( hex[0...hex.bytesize - 8] ) == hex[-8..-1]
      
      if check
        
        # Check the network version
        version = Bitcoin::NETWORKS[network][:address_version]
        
        if Bitcoin.decode_base58(address).downcase.start_with?(version.downcase)
          return true
        end
        
      end
      
      return false
    end
    
    
  end
end
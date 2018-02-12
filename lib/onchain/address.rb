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
      return Bitcoin.address_type(address) != nil
    end
    
    
  end
end
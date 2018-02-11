class OnChain::Address
  class << self
    
    def generate_address_pair(network = :bitcoin)
      key = Bitcoin::Key.generate(network)
      return key.addr, key.priv
    end
    
    def valid_address?(address, network = :bitcoin)
      return Bitcoin.address_type(address) != nil
    end
    
    
  end
end
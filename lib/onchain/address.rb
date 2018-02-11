class OnChain::Address
  class << self
    
    def generate_address_pair(network = :bitcoin)
      key = Bitcoin::Key.generate(network)
      return key.addr, key.priv
    end
    
    def validate_address(address, network = :bitcoin)
    end
    
    
  end
end
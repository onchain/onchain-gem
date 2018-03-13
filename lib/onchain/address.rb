class OnChain::Address
  class << self
    
    def generate_address_pair(network = :bitcoin)
      
      key = Bitcoin::Key.generate(network)
      
      version = Bitcoin::NETWORKS[network][:address_version]
      address = Bitcoin::encode_address(key.hash160, version)
      
      return address, key.to_base58
    end
    
    def address_from_pub_hex(pub_hex, network = :bitcoin)
      
      version = Bitcoin::NETWORKS[network][:address_version]
      hash160 = Bitcoin.hash160(pub_hex)
      address = Bitcoin::encode_address(hash160, version)
      
      return address
      
    end
    
    def address_from_wif(wif, network = :bitcoin)
      
      key = Bitcoin::Key.from_base58 wif
      
      version = Bitcoin::NETWORKS[network][:address_version]
      address = Bitcoin::encode_address(key.hash160, version)
      
      return address
    end
    
    def valid_address?(address, network = :bitcoin)
      
      if network == :ethereum
        
        a = Eth::Address.new address
        return a.valid?
        
      else
        hex = Bitcoin.decode_base58(address) rescue nil
        
        check =  Bitcoin.checksum( hex[0...hex.bytesize - 8] ) == hex[-8..-1]
        
        if check
          
          # Check the network version
          version = Bitcoin::NETWORKS[network][:address_version].downcase
          p2sh_version = Bitcoin::NETWORKS[network][:p2sh_version].downcase
          
          add = Bitcoin.decode_base58(address).downcase
          
          # Check single and multi sig version of the address.
          if add.start_with?(version) or add.start_with?(p2sh_version)
            return true
          end
          
        end
      end
      
      return false
    end
    
    
  end
end
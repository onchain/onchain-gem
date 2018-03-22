class OnChain::Etherscan
  
  ############################################################################
  # The provider methods
  
  def get_token_balance(contract, address)
    etherchain_get_token_balance(contract, address)
  end
  
  def url
    'https://api.etherscan.io/api'
  end
  ############################################################################
  
  def etherchain_get_token_balance(contract, address)
    
    cache_name = address + contract + 'tokbal'
    
    if OnChain::BlockChain.cache_read(cache_name) == nil
      
      base = url + "?module=account&action=tokenbalance&contractaddress=" 
      base = base + contract
      base = base + "&address=" + address
      base = base + '&tag=latest'
      #base = base + '&apikey=YourApiKeyToken'
      
      puts base
      
      json = OnChain::BlockChain.fetch_response(URI::encode(base))
      
      if json['result'] == nil
        bal = 0.0
      else
        bal = json['result'].to_i
      end
      
      OnChain::BlockChain.cache_write(cache_name, bal, 120)
    end
    
    return OnChain::BlockChain.cache_read(cache_name) 
  end
end
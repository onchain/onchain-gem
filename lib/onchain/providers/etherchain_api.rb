class OnChain::Etherchain
  
  ############################################################################
  # The provider methods
  def get_balance(address)
    etherchain_get_balance(address)
  end
  
  def address_history(address)
    etherchain_address_history(address)
  end
  
  def send_tx(tx_hex)
    etherchain_send_tx(tx_hex)
  end
  
  def get_transaction(tx_id)
    etherchain_get_transaction(tx_id)
  end
  
  def get_all_balances(addresses)
    etherchain_get_all_balances(addresses)
  end
  
  def get_nonce(address)
    etherchain_get_nonce(address)
  end
  
  def url
    'https://www.etherchain.org/api'
  end
  ############################################################################
  
  def etherchain_get_balance(address)
    
    if OnChain::BlockChain.cache_read(address + 'ethereum') == nil
      base = url + "/account/" + address
      
      json = OnChain::BlockChain.fetch_response(URI::encode(base))
      
      if json['balance'] == nil
        bal = 0.0
      else
        bal = json['balance'].to_f / 1_000_000_000_000_000_000.0
      end
      
      OnChain::BlockChain.cache_write(address + 'ethereum', bal, 120)
    end
    
    return OnChain::BlockChain.cache_read(address + 'ethereum') 
  end
  
  def etherchain_get_all_balances(addresses)
    
    addr = OnChain::BlockChain.get_uncached_addresses(addresses, 'ethereum')
    
    if addr.length == 0
      return
    end
    
    addr.each do |address|
      etherchain_get_balance(address)
    end
  end
  
  def etherchain_get_nonce(address)
    
    if OnChain::BlockChain.cache_read(address + 'nonce') == nil
      
      base = url + "/account/" + address + "/nonce"
      
      json = OnChain::BlockChain.fetch_response(URI::encode(base))
      
      nonce = 0
      if json['data'][0] != nil
        nonce_data = json['data'][0]['accountNonce']
        if nonce_data != nil
          nonce = nonce_data.to_i + 1
        end
      end
      
      OnChain::BlockChain.cache_write(address + 'nonce', nonce, 120)
    end
    
    return OnChain::BlockChain.cache_read(address + 'nonce') 
  end
end
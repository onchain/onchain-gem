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
  
  def url
    'https://etherchain.org/api/'
  end
  ############################################################################
  
  def etherchain_get_balance(address)
    
    base = "https://etherchain.org/api/account/" + address
    
    json = OnChain::BlockChain.fetch_response(URI::encode(base))
    
    if json['data'][0] == nil
      bal = 0
    else
      bal = json['data'][0]['balance'].to_f / 1_000_000_000_000_000_000.0
    end
    
    OnChain::BlockChain.cache_write(address, bal, 120)
    
    return bal
  end
  
  
  def etherchain_get_all_balances(addresses)
    
    addr = OnChain::BlockChain.get_uncached_addresses(addresses)
    
    if addr.length == 0
      return
    end
    
    addr.each do |address|
      etherchain_get_balance(address)
    end
  end
end
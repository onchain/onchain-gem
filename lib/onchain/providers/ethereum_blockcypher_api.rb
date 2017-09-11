class OnChain::EtherBlockCypher
  
  ############################################################################
  # The provider methods
  def get_balance(address)
    etherblockcypher_get_balance(address)
  end
  
  def address_history(address)
    etherblockcypher_address_history(address)
  end
  
  def send_tx(tx_hex)
    etherblockcypher_send_tx(tx_hex)
  end
  
  def get_transaction(tx_id)
    etherblockcypher_get_transaction(tx_id)
  end
  
  def get_all_balances(addresses)
    etherblockcypher_get_all_balances(addresses)
  end
  
  def url
    'https://api.blockcypher.com/v1/eth/main/'
  end
  ############################################################################
  
  def etherblockcypher_get_balance(address)
    
    if OnChain::BlockChain.cache_read(address + 'ethereum') == nil
      
      base_url = url + "addrs/#{address}/balance?token=#{ENV['BLOCKCYPHER_API_TOKEN']}" 
      
      json = OnChain::BlockChain.fetch_response(base_url, true)
      
      bal = 0
      if json['balance'] != nil
        bal = json['balance'].to_i / 1_000_000_000_000_000_000.0
      end
      
      OnChain::BlockChain.cache_write(address + 'ethereum', bal, 120)
    end
    
    return OnChain::BlockChain.cache_read(address + 'ethereum') 
    
  end
  
  def etherblockcypher_get_all_balances(addresses)
    
    addrs_net = addresses.map{ |a| a + 'ethereum' }
    
    addr = OnChain::BlockChain.get_uncached_addresses(addrs_net)
    
    if addr.length == 0
      return
    end
    
    addr.each do |address|
      etherblockcypher_get_balance(address)
    end
  end
  
  def etherblockcypher_send_tx(tx_hex)
    
    uri = URI.parse(url + "txs/push")		
    http = Net::HTTP.new(uri.host, uri.port)		
	
    request = Net::HTTP::Post.new(uri.request_uri)		
    request.body = '{"tx":"' + tx_hex + '"}'		
    response = http.request(request)
    
    res = JSON.parse(response.body)

    
    tx_hash = res["hash"]
    ret = "{\"status\":\"\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"\"}"	
    return JSON.parse(ret)
    
  end
end
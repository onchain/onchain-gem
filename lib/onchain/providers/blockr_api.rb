class OnChain::Blockr
  
  def initialize(url)
    @url = url
  end
  
  ############################################################################
  # The provider methods
  def get_balance(address)
    blockr_get_balance(address)
  end
  
  def address_history(address)
    blockr_address_history(address)
  end
  
  def send_tx(tx_hex)
    blockr_send_tx(tx_hex)
  end
  
  def get_unspent_outs(address)
    blockr_get_unspent_outs(address)
  end
  
  def get_transaction(tx_id)
    blockr_get_transaction(tx_id)
  end
  
  def get_all_balances(addresses)
    blockr_get_all_balances(addresses)
  end
  
  def get_address_info(address)
    blockr_get_address_info(address)
  end
  
  def url
    return @url
  end
  ############################################################################
  
  private
  
  def blockr_address_history(address, network = :bitcoin)
    
      json = blockr('address/txs', address, network)
      
      return parse_address_tx(address, json, network)
  end
  
  def parse_address_tx(address, json, network)
    
    hist = []
    if json.key?('data')
      txs = json['data']['txs']
      txs.each do |tx|
        row = {}
        row[:time] = DateTime.parse(tx["time_utc"]).to_time.to_i
        row[:addr] = {}
        row[:outs] = {}
        row[:hash] = tx["tx"]
        
        # OK, go and get the actual transaction
        tx_json = blockr('tx/info', tx["tx"], network)
        
        inputs = tx_json['data']['trade']['vins']
        val = 0
        recv = "Y"
        inputs.each do |input|
          row[:addr][input["address"]] = input["address"]
          if input["address"] == address
            recv = "N"
          end
        end
        tx_json['data']['trade']["vouts"].each do |out|
          row[:outs][out["address"]] = out["address"]
          if recv == "Y" and out["address"] == address
            val = val + out["amount"].to_f
          elsif recv == "N" and out["address"] != address
            val = val + out["amount"].to_f
          end
        end
        row[:total] = val
        row[:recv] = recv
        hist << row
      end
      return hist
    else
      'Error'
    end
    return hist
  end
  
  def blockr_send_tx(tx_hex, network = :bitcoin)	
    uri = URI.parse(@url + "tx/push")		
    http = Net::HTTP.new(uri.host, uri.port)		
	
    request = Net::HTTP::Post.new(uri.request_uri)		
    request.body = '{"hex":"' + tx_hex + '"}'		
    response = http.request(request)
    
    res = JSON.parse(response.body)

    mess = res["message"]
    stat = res["status"]
    if stat == 'fail'
      stat = 'failure'
    end
    
    tx_hash = res["data"]
    ret = "{\"status\":\"#{stat}\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"#{mess}\"}"	
    return JSON.parse(ret)
  end

  def blockr_get_balance(address, network = :bitcoin)
    if OnChain::BlockChain.cache_read(address) == nil
      json = blockr('address/balance', address, network)
      if json.key?('data')
        bal = json['data']['balance'].to_f
        OnChain::BlockChain.cache_write(address, bal, 120)
      else
        OnChain::BlockChain.cache_write(address, 'Error', 120)
      end
    end
    return OnChain::BlockChain.cache_read(address) 
  end

  def blockr_get_address_info(address, network = :bitcoin)
    
    json = blockr('address/balance', address, network)
    
    return { received: json['data']['balance'], 
      balance: json['data']['balance'],
      confirmed: json['data']['balance'] }
    
  end

  def blockr_get_transactions(address, network = :bitcoin)
    base_url = @url + "address/txs/#{address}"
    json = OnChain::BlockChain.fetch_response(base_url, true)
    
    unspent = []
    
    json['data']['txs'].each do |data|
      line = []
      line << data['tx']
      line << data['amount'].to_f 
      unspent << line
    end
    
    return unspent
  end

  def blockr_get_unspent_outs(address, network = :bitcoin)
    base_url = @url + "address/unspent/#{address}"
    json = OnChain::BlockChain.fetch_response(base_url, true)
    
    unspent = []
    
    json['data']['unspent'].each do |data|
      line = []
      line << data['tx']
      line << data['n']
      line << data['script']
      line << (data['amount'].to_f * 100000000).to_i
      unspent << line
    end
    
    return unspent
  end

  def blockr_get_all_balances(addresses, network = :bitcoin)
    
    addr = OnChain::BlockChain.get_uncached_addresses(addresses)
    
    if addr.length == 0
      return
    end
    
    base = @url + "address/balance/"
    
    addr.each do |address|
      base = base + address + ','
    end
    
    json = OnChain::BlockChain.fetch_response(URI::encode(base))
    
    json['data'].each do |data|
      bal = data['balance'].to_f
      addr = data['address']
      OnChain::BlockChain.cache_write(addr, bal, 120)
    end
  end

  def blockr_get_transaction(txhash, network = :bitcoin)
    base = @url + "tx/raw/" + txhash
    return OnChain::BlockChain.fetch_response(URI::encode(base))['data']['tx']['hex']
  end

  def blockr(cmd, address, network, params = "")

    base_url = @url + "#{cmd}/#{address}" + params
    OnChain::BlockChain.fetch_response(base_url, true)

  end
end
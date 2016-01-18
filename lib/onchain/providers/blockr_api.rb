class OnChain::BlockChain
  class << self
    
    def blockr_send_tx(tx_hex)	
      uri = URI.parse("http://btc.blockr.io/api/v1/tx/push")		
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

    def blockr_get_balance(address)
      if cache_read(address) == nil
        json = blockr('address/balance', address)
        if json.key?('data')
          bal = json['data']['balance'].to_f
          cache_write(address, bal, BALANCE_CACHE_FOR)
        else
          cache_write(address, 'Error', BALANCE_CACHE_FOR)
        end
      end
      return cache_read(address) 
    end

    def blockr_get_address_info(address)
      
      json = blockr('address/balance', address)
      
      return { received: json[address]['total_received'], 
        balance: json[address]['final_balance'],
        confirmed: json[address]['final_balance'] }
      
    end

    def blockr_get_transactions(address)
      base_url = "http://btc.blockr.io/api/v1/address/txs/#{address}"
      json = fetch_response(base_url, true)
      
      unspent = []
      
      json['data']['txs'].each do |data|
        line = []
        line << data['tx']
        line << data['amount'].to_f 
        unspent << line
      end
      
      return unspent
    end

    def blockr_get_unspent_outs(address)
      base_url = "http://btc.blockr.io/api/v1/address/unspent/#{address}"
      json = fetch_response(base_url, true)
      
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

    def blockr_get_all_balances(addresses)
      
      addr = get_uncached_addresses(addresses)
      
      if addr.length == 0
        return
      end
      
      base = "https://blockr.io/api/v1/address/balance/"
      
      addr.each do |address|
        base = base + address + ','
      end
      
      json = fetch_response(URI::encode(base))
      
      json['data'].each do |data|
        bal = data['balance'].to_f
        addr = data['address']
        cache_write(addr, bal, BALANCE_CACHE_FOR)
      end
    end
  
    def blockr(cmd, address, params = "")

      base_url = "http://blockr.io/api/v1/#{cmd}/#{address}" + params
      fetch_response(base_url, true)

    end
  end
end
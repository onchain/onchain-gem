class OnChain::BlockChain
  class << self
    
    def get_insight_url(network)
      if network == :bitcoin
        return "https://insight.bitpay.com/api/"
      elsif network == :zcash_testnet
        return "https://explorer.testnet.z.cash/api/"
      end
      return "https://test-insight.bitpay.com/api/"
    end
      
    def insight_address_history(address, network = :bitcoin)
        
      base_url = get_insight_url(network) + "addr/" + address
      json = fetch_response(base_url, true) 
      
      return parse_insight_address_tx(address, json, network)
        
    end
    
    def parse_insight_address_tx(address, json, network)
      
      hist = []
      if json.key?('transactions')
        txs = json['transactions']
        txs.each do |tx|
          row = {}
          row[:hash] = tx[tx]
          
          # OK, go and get the actual transaction
          base_url = get_insight_url(network) + "tx/" + tx
          tx_json = fetch_response(base_url, true) 
          
          row[:time] = tx_json["time"]
          row[:addr] = {}
          row[:outs] = {}
          
          inputs = tx_json['vin']
          val = 0
          recv = "Y"
          inputs.each do |input|
            row[:addr][input["addr"]] = input["addr"]
            if input["addr"] == address
              recv = "N"
            end
          end
          
          tx_json["vout"].each do |out|
            out_addr = out["scriptPubKey"]["addresses"][0]
            row[:outs][out_addr] = out_addr
            if recv == "Y" and out_addr == address
              val = val + out["value"].to_f
            elsif recv == "N" and out_addr != address
              val = val + out["value"].to_f
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
    
    def insight_send_tx(tx_hex, network = :bitcoin)
        
      uri = URI.parse(get_url(network) + "tx/push")		
      http = Net::HTTP.new(uri.host, uri.port)		
		
      request = Net::HTTP::Post.new(uri.request_uri)		
      request.body = '{"rawtx":"' + tx_hex + '"}'		
      response = http.request(request)
      
      res = JSON.parse(response.body)

      mess = 'Unknown'
      stat = 'Unknown'
      tx_hash = res["txid"]
      
      ret = "{\"status\":\"#{stat}\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"#{mess}\"}"	
      return JSON.parse(ret)	
    end

    def insight_get_balance(address, network = :bitcoin)
        
      if cache_read(address + network.to_s) == nil
        
        base_url = get_insight_url(network) + "addr/#{address}/balance" 
        bal_string = fetch_response(base_url, false) 
        bal = bal_string.to_i / 100000000.0
        cache_write(address + network.to_s, bal, BALANCE_CACHE_FOR)
      end
      
      return cache_read(address + network.to_s) 
    end

    def insight_get_all_balances(addresses, network = :bitcoin)
      
      addresses.each do |address|
        insight_get_balance(address, network)
      end
    end

    def insight_get_unspent_outs(address, network = :bitcoin)
        
      base_url = get_insight_url(network) + "addr/#{address}/utxo"
      json = fetch_response(base_url, true)
      
      unspent = []
      
      json.each do |data|
        line = []
        line << data['txid']
        line << data['vout']
        line << data['scriptPubKey']
        line << (data['amount'].to_f * 100000000).to_i
        unspent << line
      end
      
      return unspent
    end

    def insight_get_transaction(txhash, network = :bitcoin)
      base = get_insight_url(network) + "rawtx/" + txhash
      return fetch_response(URI::encode(base))['rawtx']
    end
    
  end
end
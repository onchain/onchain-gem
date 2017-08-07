class OnChain::Insight
  
  # We limit the history as it makes repeated calls back to the API.  
  def initialize(url, history_limit = 6)
    @url = url
    @history_limit = history_limit
  end
  
  ############################################################################
  # The provider methods
  def get_balance(address)
    insight_get_balance(address)
  end
  
  def address_history(address)
    insight_address_history(address)
  end
  
  def send_tx(tx_hex)
    insight_send_tx(tx_hex)
  end
  
  def get_unspent_outs(address)
    insight_get_unspent_outs(address)
  end
  
  def get_transaction(tx_id)
    insight_get_transaction(tx_id)
  end
  
  def get_all_balances(addresses)
    insight_get_all_balances(addresses)
  end
  
  def url
    return @url
  end
  ############################################################################
  
  private
    
  def insight_address_history(address, network = :bitcoin)
      
    base_url = @url + "addr/" + address
    json = OnChain::BlockChain.fetch_response(base_url, true) 
    
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
        base_url = @url + "tx/" + tx
        tx_json = OnChain::BlockChain.fetch_response(base_url, true) 
        
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
        
        if hist.count == @history_limit
          break
        end
      end
      return hist
    else
      'Error'
    end
    return hist
  end
  
  def insight_send_tx(tx_hex, network = :bitcoin)
    
    uri = URI.parse(@url + "tx/send")		
    http = Net::HTTP.new(uri.host, uri.port)
    if @url.start_with? 'https'
      http.use_ssl = true	
    end
	
    request = Net::HTTP::Post.new(uri.request_uri)		
    request.body = "rawtx: #{tx_hex}"		
    response = http.request(request)
    
    begin 
      res = JSON.parse(response.body)
      tx_hash = res["txid"]
    rescue  
      tx_hash = response.body.strip
    end

    mess = 'Unknown'
    stat = 'Unknown'
    
    ret = "{\"status\":\"#{stat}\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"#{mess}\"}"	
    return JSON.parse(ret)	
  end

  def insight_get_balance(address, network = :bitcoin)
    
    if OnChain::BlockChain.cache_read(address + network.to_s) == nil
      
      base_url = @url + "addr/#{address}/balance" 
      bal_string = OnChain::BlockChain.fetch_response(base_url, false) 
      bal = bal_string.to_i / 100000000.0
      OnChain::BlockChain.cache_write(address + network.to_s, bal, 120)
    end
    
    return OnChain::BlockChain.cache_read(address + network.to_s) 
  end

  def insight_get_all_balances(addresses, network = :bitcoin)
    
    addresses.each do |address|
      insight_get_balance(address, network)
    end
  end

  def insight_get_unspent_outs(address, network = :bitcoin)
      
    base_url = @url + "addr/#{address}/utxo"
    json = OnChain::BlockChain.fetch_response(base_url, true)
    
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
    base = @url + "rawtx/" + txhash
    return OnChain::BlockChain.fetch_response(URI::encode(base))['rawtx']
  end
    
end
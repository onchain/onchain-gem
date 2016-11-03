# This only works with nodes that have addrindex patch applied.
# i.e. https://github.com/dexX7/bitcoin
class OnChain::BlockChain
  class << self
      
    def bitcoind_address_history(address, network = :bitcoin)
        
      base_url = get_insight_url(network) + "addr/" + address
      json = fetch_response(base_url, true) 
      
      return parse_insight_address_tx(address, json, network)
        
    end
    
    def parse_bitcoind_address_tx(address, json, network)
      
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
    
    def bitcoind_send_tx(tx_hex, network = :bitcoin)
      
      return OnChain::BlockChain.blockr_send_tx(tx_hex, network)
        
      #uri = URI.parse(get_url(network) + "tx/send")		
      #http = Net::HTTP.new(uri.host, uri.port)		
		
      #request = Net::HTTP::Post.new(uri.request_uri)		
      #request.body = '{"rawtx":"' + tx_hex + '"}'		
      #response = http.request(request)
      
      #res = JSON.parse(response.body)

      #mess = 'Unknown'
      #stat = 'Unknown'
      #tx_hash = res["txid"]
      
      #puts 'Call insight_send_tx ' + tx_hex.to_s
      
      #ret = "{\"status\":\"#{stat}\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"#{mess}\"}"	
      #return JSON.parse(ret)	
    end

    def bitcoind_get_balance(address, network = :bitcoin)
        
      return execute_remote_command('zcash-cli getinfo', network)
    end

    def bitcoind_get_all_balances(addresses, network = :bitcoin)
      
      addresses.each do |address|
        insight_get_balance(address, network)
      end
    end

    def bitcoind_get_unspent_outs(address, network = :bitcoin)
        
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

    def bitcoind_get_transaction(txhash, network = :bitcoin)
      base = get_insight_url(network) + "rawtx/" + txhash
      return fetch_response(URI::encode(base))['rawtx']
    end
    
    private
    
    # Run the command via ssh. For this to work you need
    # to create the follwing ENV vars.
    def execute_remote_command(cmd, network)

      host = ENV[network.to_s.upcase + '_HOST']
      username = ENV[network.to_s.upcase + '_USER']
      password = ENV[network.to_s.upcase + '_PASSWORD']
      
      cmd = ENV[network.to_s.upcase + '_LOCATION'] + cmd 

      stdout  = ""
      stderr = ""
      Net::SSH.start(host, username, password: password)  do |ssh|
        ssh.exec! cmd do |channel, stream, data|
          stdout << data if stream == :stdout
          stderr << data if stream == :stderr
        end
        # ssh.close
      end
      
      return stdout
    end
    
  end
end
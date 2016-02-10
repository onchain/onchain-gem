class OnChain::BlockChain
  class << self

    
    def blockinfo_get_history_for_addresses(addresses)
      history = []
      addresses.each do |address|
        res = blockinfo_address_history(address)
        res.each do |r|
          history << r
        end
      end
      return history
    end
  
    def blockinfo_address_history(address)
      
      base_url = "https://blockchain.info/address/#{address}?format=json"
      json = fetch_response(base_url, true)
      
      blockinfo_parse_address_tx(address, json)
    end
    
    def blockinfo_parse_address_tx(address, json)
      
      hist = []
      if json.key?('txs')
        txs = json['txs']
        txs.each do |tx|
          row = {}
          row[:time] = tx["time"]
          row[:addr] = {}
          row[:outs] = {}
          inputs = tx['inputs']
          val = 0
          recv = "Y"
          inputs.each do |input|
            row[:addr][input["prev_out"]["addr"]] = input["prev_out"]["addr"]
            if input["prev_out"]["addr"] == address
              recv = "N"
            end
          end
          tx["out"].each do |out|
            row[:outs][out["addr"]] = out["addr"]
            if recv == "Y" and out["addr"] == address
              val = val + out["value"].to_f / 100000000.0
            elsif recv == "N" and out["addr"] != address
              val = val + out["value"].to_f / 100000000.0
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

    def blockinfo_get_address_info(address)
      
      base = "https://blockchain.info/multiaddr?&simple=true&active=" + address
      
      json = fetch_response(URI::encode(base))
      
      return { received: json[address]['total_received'], 
        balance: json[address]['final_balance'],
        confirmed: json[address]['final_balance'] }
      
    end

    def blockinfo_get_all_balances(addresses)
      base = "https://blockchain.info/multiaddr?&simple=true&active="
      
      addr = get_uncached_addresses(addresses)
      
      if addr.length == 0
        return
      end
      
      addr.each do |address|
        base = base + address + '|'
      end
      
      json = fetch_response(URI::encode(base))
      
      addresses.each do |address|
        bal = json[address]['final_balance'] / 100000000.0
        cache_write(address, bal, BALANCE_CACHE_FOR)
      end
    end

    def blockinfo_get_unspent_outs(address)
      base_url = "https://blockchain.info/unspent?active=#{address}"
      json = fetch_response(base_url, true)
      
      unspent = []
      
      json['unspent_outputs'].each do |data|
        line = []
        line << reverse_blockchain_tx(data['tx_hash'])
        line << data['tx_output_n']
        line << data['script']
        line << data['value']
        unspent << line
      end
      
      return unspent
    end

    def blockinfo_get_balance(address)
      if cache_read(address) == nil
        json = block_chain('address', address, "&limit=0")
        if json.key?('final_balance')
          bal = json['final_balance'] / 100000000.0
          cache_write(address, bal, BALANCE_CACHE_FOR)
        else
          cache_write(address, 'Error', BALANCE_CACHE_FOR)
        end
      end
      bal = cache_read(address)
      if bal.class == Fixnum
        bal = bal.to_f
      end
      return bal
    end

    def blockinfo_get_transaction(txhash)
      base = "https://blockchain.info/rawtx/#{txhash}?format=hex"
      return fetch_response(URI::encode(base))
    end
  
    def block_chain(cmd, address, params = "")
      base_url = "https://blockchain.info/#{cmd}/#{address}?format=json" + params
      
      fetch_response(base_url, true)
    end
    
    def reverse_blockchain_tx(hash)
       bytes = hash.scan(/../).map { |x| x.hex.chr }.join
       
       bytes = bytes.reverse
       
       return hash.scan(/../).reverse.join
    end
    
  end
end
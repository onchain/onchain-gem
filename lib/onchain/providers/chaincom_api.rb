require 'chain'

class OnChain::BlockChain
  class << self

    
    def chaincom_get_history_for_addresses(addresses)
      
      array_tx_objects = Chain.get_address_transactions(addresses)
      
      history = []
      for i in 0..addresses.count
        res = chaincom_parse_address_tx(addresses[i], array_tx_objects[i])
        res.each do |r|
          history << r
        end
      end
      return history
    end
    
    def chaincom_address_history(address)
      
      txs = Chain.get_address_transactions(address)
      
      return chaincom_parse_address_tx(address, txs)
    end
    
    def chaincom_parse_address_tx(address, txs)
      hist = []
      txs.each do |tx|
        row = {}
        row[:time] = Date.parse(Time.at(tx["block_time"].to_i).to_s)
        row[:addr] = {}
        row[:outs] = {}
        inputs = tx['inputs']
        val = 0
        recv = "Y"
        inputs.each do |input|
          row[:addr][input["addresses"][0]] = input["addresses"][0]
          if input["addresses"][0] == address
            recv = "N"
          end
        end
        tx["outputs"].each do |out|
          row[:outs][out["addresses"][0] ] = out["addresses"][0] 
          if recv == "Y" and out["addresses"][0]  == address
            val = val + out["value"].to_f / 100000000.0
          elsif recv == "N" and out["addresses"][0]  != address
            val = val + out["value"].to_f / 100000000.0
          end
        end
        row[:total] = val
        row[:recv] = recv
        hist << row
      end
      return hist
    end
    
    def chaincom_send_tx(tx_hex)	
      
      begin
        tx = Chain.send_transaction(tx_hex)
        tx_hash = tx["transaction_hash"]
        ret = "{\"status\":\"success\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"\"}"
        return JSON.parse(ret)
      rescue => e
        ret = "{\"status\":\"failure\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"#{e.to_s}\"}"
        return JSON.parse(ret)
      end	
    end

    def chaincom_get_balance(address)
      if cache_read(address) == nil
        
        addr = Chain.get_address(address)
        if addr.count > 0
          bal = addr[0]["total"]["balance"].to_i / 100000000.0
          cache_write(address, bal, BALANCE_CACHE_FOR)
        end
        
      end
      return cache_read(address) 
    end

    def chaincom_get_transactions(address)
      
      txs = Chain.get_address_transactions(address)
      
      unspent = []
      
      txs.each do |data|
        line = []
        line << data['hash']
        line << data["outputs"][0]["value"] / 100000000.0
        unspent << line
      end
      
      return unspent
    end

    def chaincom_get_unspent_outs(address)
      
      uns = Chain.get_address_unspents(address)
      
      unspent = []
      
      uns.each do |data|
        line = []
        line << data['transaction_hash']
        line << data['output_index']
        line << data['script_hex']
        line << data['value']
        unspent << line
      end
      
      return unspent
    end

    def chaincom_get_all_balances(addresses)
      
      addr = get_uncached_addresses(addresses)
      
      if addr.length == 0
        return
      end
      
      res = Chain.get_addresses(addr)
      
      if ! res.kind_of?(Array)
        res = [res]
      end
      
      res.each do |address|
        bal = address["total"]["balance"] / 100000000.0
        cache_write(address["address"], bal, BALANCE_CACHE_FOR)
      end
    end
  end
end
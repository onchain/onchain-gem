require 'chain'

class OnChain::BlockChain
  class << self
    
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
        bal = addr["balance"] / 100000000.0
        cache_write(address, bal, BALANCE_CACHE_FOR)
        
      end
      return cache_read(address) 
    end

    def chaincom_get_transactions(address)
      
      txs = Chain.get_address_transactions(address)
      
      unspent = []
      
      txs.each do |data|
        line = []
        line << data['hash']
        line << data['amount'] / 100000000.0
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
        bal = address["balance"] / 100000000.0
        cache_write(address["hash"], bal, BALANCE_CACHE_FOR)
      end
    end
  end
end
class OnChain::BlockChain
  class << self

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

    def blockr_get_transactions(address)
      base_url = "http://btc.blockr.io/api/v1/address/txs/#{address}"
      json = fetch_response(base_url, true)
      
      unspent = []
      
      json['data']['txs'].each do |data|
        line = []
        line << data['tx']
        line << (data['amount'].to_f * 100000000).to_i
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
      base = "https://blockr.io/api/v1/address/balance/"
      
      addresses.each do |address|
        base = base + address + ','
      end
      
      json = fetch_response(URI::encode(base))
      
      json['data'].each do |data|
        bal = data['balance']
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
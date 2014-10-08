class OnChain::BlockChain
  class << self


    def blockinfo_get_all_balances(addresses)
      base = "https://blockchain.info/multiaddr?&simple=true&active="
      
      addresses.each do |address|
        base = base + address + '|'
      end
      
      json = fetch_response(URI::encode(base))
      
      addresses.each do |address|
        bal = json[address]['final_balance'] / 100000000.0
        cache_write(address, bal, BALANCE_CACHE_FOR)
      end
    end

    def blockinfo_get_unspent_outs(address)
      base_url = "http://blockchain.info/unspent?active=#{address}"
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
  
    def block_chain(cmd, address, params = "")
      base_url = "http://blockchain.info/#{cmd}/#{address}?format=json" + params
      
      fetch_response(base_url, true)
    end
    
    def reverse_blockchain_tx(hash)
       bytes = hash.scan(/../).map { |x| x.hex.chr }.join
       
       bytes = bytes.reverse
       
       return hash.scan(/../).reverse.join
    end
    
  end
end
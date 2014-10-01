require 'net/http'
require 'json'

class OnChain
  class << self
    
    BALANCE_CACHE_FOR = 120
    API_CACHE_FOR = 60
    
    @@cache = {}
    
    def cache_write(key, data, max_age=0)
       @@cache[key] = [Time.now, data, max_age]
    end
    
    def cache_read(key)
       # if the API URL exists as a key in cache, we just return it
       # we also make sure the data is fresh
       if @@cache.has_key? key
          return @@cache[key][1] if Time.now-@@cache[key][0] < @@cache[key][2]
       end
    end
    
    
    def get_all_balances(addresses)

      if ! blockr_down?
        bal = blockr_get_all_balances(addresses)
        return bal
      end
      
      if ! blockchain_down?
        bal = blockinfo_get_all_balances(addresses)
        return bal
      end
    end
    
    def get_balance(address)
      
      # These guys make 300k per month so hammer them first.
      if ! blockchain_down?
        bal = blockinfo_balance(address)
        if ! bal.instance_of? String
          return bal
        end
      end
      
      # Looks like blockchain is down, let's try blockr
      if ! blockr_down?
        bal = blockr_balance(address)
        if ! bal.instance_of? String
          return bal
        end
      end
      
      # OK I give up.
      'Balance could not be retrieved'
    end
    
    def send_tx(tx_hex)
      #payload = { :tx => tx_hex }
      #HTTParty.post('http://blockchain.info/pushtx', {:body => payload})
      
      # Blockchain doesn't support multi sig, so only use blockr
      uri = URI.parse("http://btc.blockr.io/api/v1/tx/push")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = '{"hex":"' + tx_hex + '"}'
      response = http.request(request)
      return response
    end
    
    def get_history
      return []
    end
    
    def get_unspent_outs(address)

      
      # Looks like blockchain is down, let's try blockr
      if ! blockr_down?
        return blockr_unspent(address)
      end
      
      if ! blockchain_down?
        return blockinfo_unspent(address)
      end
      
      # OK I give up.
      'Unspent outputs could not be retrieved'
      
    end

    def blockchain_is_down
      cache_write(:blockchainapi, 'it is down', 60)
    end

    def blockchain_down?
      if cache_read(:blockchainapi) != nil
        return true
      end
      return false
    end

    def blockr_is_down
      cache_write(:blockrapi, 'it is down', 60)
    end

    def blockr_down?
      if cache_read(:blockrapi) != nil
        return true
      end
      return false
    end

    def blockinfo_get_all_balances(addresses)
      begin
        base = "https://blockchain.info/multiaddr?&simple=true&active="
        
        addresses.each do |address|
          base = base + address + '|'
        end
        
        json = fetch_response(URI::encode(base))
        
        addresses.each do |address|
          bal = json[address]['final_balance'] / 100000000.0
          cache_write(address, bal, BALANCE_CACHE_FOR)
        end
        
      rescue
        'Balance could not be retrieved'
      end
    end

    def blockinfo_unspent(address)
      begin
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
      rescue Exception => e
        puts e.to_s
        'Unspent outputs could not be retrieved'
      end
    end

    def blockinfo_balance(address)
      begin
        if cache_read(address) == nil
          puts "cache is empty"
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
      rescue
        'Balance could not be retrieved'
      end
    end

    def blockr_unspent(address)
      begin
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
      rescue Exception => e
        puts e.to_s
        'Unspent outputs could not be retrieved'
      end
    end

    def blockr_get_all_balances(addresses)
      begin
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
        
      rescue
        'Balance could not be retrieved'
      end
    end

    def blockr_balance(address)
      begin
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
      rescue Exception => e  
        puts e
        'Balance could not be retrieved'
      end
    end
  
    def blockr(cmd, address, params = "")
      if ! blockr_down?
        begin
          base_url = "http://blockr.io/api/v1/#{cmd}/#{address}" + params
          fetch_response(base_url, true)
        rescue
          blockr_is_down
        end
      end
    end
  
    def block_chain(cmd, address, params = "")
      if ! blockchain_down?
        begin
          base_url = "http://blockchain.info/#{cmd}/#{address}?format=json" + params
          
          puts base_url
          fetch_response(base_url, true)
        rescue
          blockchain_is_down
        end
      end
    end
  
    def fetch_response(url, do_json=true)
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
    
      if do_json
        result = JSON.parse(data)
      else
        data
      end
    end
    
    def reverse_blockchain_tx(hash)
       bytes = hash.scan(/../).map { |x| x.hex.chr }.join
       
       bytes = bytes.reverse
       
       return hash.scan(/../).reverse.join
    end
    
    
  end
end
require 'net/http'
require 'json'

# We support a number of blockchain API providers,
# if one goes down we automatically switch over to another.
#
# Each provider has to support the following methods
#
# get_balance(address)
# get_all_balances([])
# send_tx(tx_hex)
# get_transactions(address)
#
class OnChain
end

class OnChain::BlockChain
  class << self
    
    ALL_SUPPLIERS = [:chaincom, :blockr, :blockinfo ] 
    #ALL_SUPPLIERS = [ :blockr, :blockinfo ] 
    
    def method_missing (method_name, *args, &block)
      
      get_available_suppliers(method_name).each do |supplier|

        real_method = "#{supplier.to_s}_#{method_name}"
        begin
          method = self.method(real_method)
          begin
            result = method.call(*args)
            return result
          rescue => e2
            # We have the method but it errored. Assume
            # service is down.
            cache_write(supplier.to_s, 'down', SERVICE_DOWN_FOR)
            puts e2.to_s
          end
        rescue => e
          puts "there's no method called '#{real_method}'"
          puts e.backtrace
        end
      end
      
    end
    
    def get_balance_satoshi(address)
      return (get_balance(address).to_f * 100000000).to_i
    end
    
    def get_available_suppliers(method_name)
      available = []
      ALL_SUPPLIERS.each do |supplier|
        if cache_read(supplier.to_s) == nil
          
          if supplier == :blockinfo and method_name == 'send_tx'
            next
          end
          
          if supplier == :blockinfo and method_name == 'get_transactions'
            next
          end
          
          available << supplier
        end
      end
      return available
    end
    
    BALANCE_CACHE_FOR = 120
    API_CACHE_FOR = 60
    SERVICE_DOWN_FOR = 60
    
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
    
    def fetch_response(url, do_json=true)
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
    
      if do_json
        result = JSON.parse(data)
      else
        data
      end
    end
    
  end
end
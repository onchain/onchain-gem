require 'net/http'
require 'net/ssh'
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
  class << self
  
    def bin_to_hex(bin)
      return bin.unpack("H*")[0]
    end
  
    def hex_to_bin(hex)
      return hex.scan(/../).map { |x| x.hex }.pack('c*')
    end
  end
end

class OnChain::BlockChain
  class << self
    
    ALL_SUPPLIERS = [ :blockinfo, :insight, :blockr, :bitcoind ] 
    
    def method_missing (method_name, *args, &block)
      
      network = :bitcoin
      # List of allowable networks.
      if  args.length > 0
        if [:testnet3, :zcash_testnet, :zcash, :zclassic].include? args[args.length - 1]
          network = args[args.length - 1]
        end
      end
      
      get_available_suppliers(method_name, network).each do |supplier|

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
            puts e2.backtrace
          end
        rescue => e
          puts "there's no method called '#{real_method}'"
          puts e.backtrace
        end
      end
      
    end
    
    # Given a list of addresses, return those
    # that don't have balances in the cahce.
    def get_uncached_addresses(addresses)
      ret = []
      addresses.each do |address|
        if cache_read(address) == nil
          ret << address
        end
      end
      return ret
    end
    
    def get_unspent_for_amount(addresses, amount_in_satoshi, network = :bitcoin)
      
      unspents = []
      indexes = []
      amount_so_far = 0
      
      addresses.each_with_index do |address, index|

        if amount_so_far >= amount_in_satoshi
          break
        end
        
        unspent_outs = get_unspent_outs(address, network)
        
        unspent_outs.each do |spent|

          unspents << spent
          indexes << index
          
          amount_so_far = amount_so_far + spent[3].to_i
          if amount_so_far >= amount_in_satoshi
            break
          end
        end
      end
      
      change = amount_so_far - amount_in_satoshi 
      return unspents, indexes, change
      
    end
    
    def get_balance_satoshi(address, network = :bitcoin)
      return (get_balance(address, network).to_f * 100000000).to_i
    end
    
    def get_available_suppliers(method_name, network)
      available = []
      ALL_SUPPLIERS.each do |supplier|
        if cache_read(supplier.to_s) == nil
          
          if supplier == :blockinfo and ! [:bitcoin].include? network
            next
          end
          
          if supplier == :blockr and ! [:bitcoin, :testnet3].include? network
            next
          end
          
          if supplier == :insight and ! [:bitcoin].include? network
            next
          end
          
          if supplier == :bitcoind and ENV[network.to_s.upcase + '_HOST'] == nil
            next
          end
          
          if supplier == :blockinfo and method_name.to_s == 'send_tx'
            next
          end
          
          if supplier == :blockinfo and method_name.to_s == 'get_transactions'
            next
          end
          
          if supplier == :blockr and network == :bitcoin and method_name.to_s == 'address_history'
            next
          end
          
          if supplier == :blockr and method_name.to_s == 'get_address_info'
            next
          end
          
          if supplier == :insight and method_name.to_s == 'get_address_info'
            next
          end
          
          if supplier == :blockr and network == :bitcoin and method_name.to_s == 'get_history_for_addresses'
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
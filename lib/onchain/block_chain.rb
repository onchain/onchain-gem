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
  
  # APIS are stored in order of preference.
  # TODO get_address_info for insight and test send_tx for blockchain.info
  COINS = {
    :bitcoin => {
      :apis => [
        { :provider => OnChain::BlockChaininfo.new,
          # Exclude send_tx as it doesn't support multi sig.
          :excludes => [:send_tx]},
        { :provider => OnChain::Insight.new('https://insight.bitpay.com/api/', :bitcoin),
          :excludes => [:get_address_info] },
        { :provider => OnChain::Blockr.new('http://btc.blockr.io/api/v1/') },
      ]
    },
    :testnet3 => {
      :apis => [
        { :provider => OnChain::Insight.new('https://testnet.blockexplorer.com/api/', :testnet3),
          :excludes => [:get_address_info] },
        { :provider => OnChain::Insight.new('https://test-insight.bitpay.com/api/', :testnet3),
          :excludes => [:get_address_info] },
        { :provider => OnChain::Blockr.new('http://tbtc.blockr.io/api/v1/') }
      ]
    },
    :zcash_testnet => {
      :apis => [
        { :provider => OnChain::Insight.new('https://explorer.testnet.z.cash/api/', :zcash_testnet),
          :excludes => [:get_address_info] }
      ] 
    },
    :zcash => {
      :apis => [
        { :provider => OnChain::Insight.new('https://zcash.blockexplorer.com/api/', :zcash),
          :excludes => [:get_address_info] }
      ] 
    },
    :zclassic => {
      :apis => [
        # http://149.56.129.104/insight-api-zcash/peer
        # https://zcl-explorer.com/insight-api-zcash/
        { :provider => OnChain::Insight.new('http://explorer.zclassicblue.org:3001/insight-api-zcash/', :zclassic),
          :excludes => [:get_address_info] }
      ] 
    },
    :bitcoin_cash => {
      :apis => [
        { :provider => OnChain::Insight.new('https://cashexplorer.bitcoin.com/api/', :bitcoin_cash),
          :excludes => [:get_address_info]}
      ] 
    },
    :bitcoin_gold => {
      :apis => [
        { :provider => OnChain::Insight.new('https://explorer.bitcoingold.org/insight-api/', :bitcoin_gold),
          :excludes => [:get_address_info]}
      ] 
    },
    :ethereum => {
      :apis => [
        { :provider => OnChain::Etherchain.new,
          :excludes => [:get_address_info, :get_unspent_outs, :send_tx,
          :get_token_balance]},
        { :provider => OnChain::Etherscan.new,
          :excludes => [:get_balance, :get_address_info, :get_unspent_outs, 
          :send_tx, :get_address_info, :get_unspent_outs, :get_next_nonce]}
      ] 
    },
    :litecoin => {
      :apis => [
        { :provider => OnChain::Insight.new('https://insight.litecore.io/api/', :litecoin),
          :excludes => [:get_address_info]},
      ] 
    },
    :dash => {
      :apis => [
        { :provider => OnChain::Insight.new('https://insight.dash.org/insight-api-dash/', :dash),
          :excludes => [:get_address_info]},
      ] 
    },
    :bitcoin_private => {
      :apis => [
        { :provider => OnChain::Insight.new('https://explorer.btcprivate.org/api/', :bitcoin_private),
          :excludes => [:get_address_info]},
      ] 
    }
    
  }
  
  # If we have a BlockCypher token, add the blockcypher service.
  if ENV["BLOCKCYPHER_API_TOKEN"] != nil
    block_ether = { :provider => OnChain::EtherBlockCypher.new,
          :excludes => [:get_address_info, :get_unspent_outs, 
            :get_next_nonce, :get_token_balance]}
          
    COINS[:ethereum][:apis].unshift block_ether
  end
  
  class << self
    
    ############################################################################
    # The provider methods
    def get_balance(address, network = :bitcoin)
      return call_api_method(:get_balance, network, address)
    end
    
    # The total balance included unconfirmed transactions.
    def get_unconfirmed_balance(address, network = :bitcoin)
      return call_api_method(:get_unconfirmed_balance, network, address)
    end
    
    def address_history(address, network = :bitcoin)
      return call_api_method(:address_history, network, address)
    end
    
    def send_tx(tx_hex, network = :bitcoin)
      return call_api_method(:send_tx, network, tx_hex)
    end
    
    def get_unspent_outs(address, network = :bitcoin)
      return call_api_method(:get_unspent_outs, network, address)
    end
    
    def get_transaction(tx_id, network = :bitcoin)
      return call_api_method(:get_transaction, network, tx_id)
    end
  
    def get_all_balances(addresses, network = :bitcoin)
      return call_api_method(:get_all_balances, network, addresses)
    end
  
    def get_address_info(addresses, network = :bitcoin)
      return call_api_method(:get_address_info, network, addresses)
    end
  
    def get_next_nonce(address, network = :ethereum)
      return call_api_method(:get_next_nonce, network, address)
    end
  
    def get_token_balance(contract, address, decimalplaces, 
        network = :ethereum)
      return call_api_method(:get_token_balance, network, contract, 
        address, decimalplaces)
    end
    ############################################################################
    
    # We assume these are the exception if the provider is having an issue.
    NET_HTTP_RESCUES = [ Errno::EINVAL,
      Errno::ECONNRESET,
      EOFError,
      Net::HTTPBadResponse,
      Net::HTTPHeaderSyntaxError,
      Net::ProtocolError,
      Net::OpenTimeout,
      Net::HTTPServerException,
      Net::HTTPFatalError,
      Errno::EHOSTUNREACH,
      Net::HTTPRetriableError ]
      
    def call_api_method (method_name, network, *args)
       
      if COINS[network] == nil
        raise 'Network ' + network.to_s + ' not supported'
      end
      
      providers = get_available_suppliers(method_name, network)
      
      # Call each provider until we get an answer
        
      error = ''
        
      providers.each do |provider|
        
        method = provider.method(method_name)
        
        if ! provider.class.method_defined? method_name
          raise "Provider doesn't have method " + method_name
        end
        begin
          result = method.call(*args)
          return result
        rescue JSON::ParserError => e
          # It's fine continue to the next provider
          error = e.backtrace.join("\n")
        rescue StandardError => e2
          # We have the method but it errored. Assume
          # service is down.
          error = e2.backtrace.join("\n")
          if NET_HTTP_RESCUES.include? e2
            cache_write(provider.url, error, SERVICE_DOWN_FOR)
          end
        end
        
      end
      
      raise "No available providers for #{method_name.to_s} : #{network.to_s} : #{error}"
      
    end
    
    def get_available_suppliers(method_name, network)
      
      if COINS[network] == nil
        raise 'Network ' + network.to_s + ' not supported'
      end
      
      providers = []
      
      COINS[network][:apis].each do |api|
        
        # Is the service temporarily down?
        if cache_read(api[:provider].url) != nil
          next
        end  
          
        # we can exclude some providers
        if api[:excludes] != nil and api[:excludes].include? method_name
          next
        end
        
        providers << api[:provider]
        
      end
      
      return providers
    end

    def get_history_for_addresses(addresses, network = :bitcoin)
      history = []
      addresses.each do |address|
        if get_balance(address, network) > 0
          res = address_history(address, network)
          res.each do |r|
            history << r
          end
        end
      end
      return history
    end
    
    # Given a list of addresses, return those
    # that don't have balances in the cahce.
    def get_uncached_addresses(addresses, suffix = '')
      ret = []
      addresses.each do |address|
        if cache_read(address + suffix) == nil
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
        JSON.parse(data)
      else
        data
      end
    end
    
    def status
        
      the_status = ''
      
      COINS.keys.each do |network| 
        
        COINS[network][:apis].each do |provider|
          
          url = provider[:provider].url
          
          the_status += url
          
          if cache_read(url) != nil
            the_status += ':Down:' + cache_read(url).to_s
          else
            the_status += ':Up'
          end
          
          the_status += "\n"
          
        end
        
      end
      
      return the_status
      
    end
    
  end
end
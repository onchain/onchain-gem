# This only works with nodes that have addrindex patch applied.
# i.e. https://github.com/dexX7/bitcoin
class OnChain::BlockChain
  class << self
     
    # Get last 20 transactions  
    def bitcoind_address_history(address, network = :bitcoin)
        
      result = execute_remote_command('searchrawtransactions ' + address + ' 1 0 20 0', network)
      
      json = JSON.parse result 
      
      return parse_bitcoind_address_tx(address, json, network)
        
    end

    def bitcoind_get_history_for_addresses(addresses, network = :bitcoin)
      history = []
      addresses.each do |address|
        res = bitcoind_address_history(address, network)
        res.each do |r|
          history << r
        end
      end
      return history
    end
    
    def parse_bitcoind_address_tx(address, json, network)
      
      hist = []
      json.each do |tx|
        
        
        row = {}
        row[:hash] = tx['txid']
        
        row[:time] = tx['time']
        row[:addr] = {}
        row[:outs] = {}
        
        inputs = tx['vin']
        val = 0
        recv = "Y"
        inputs.each do |input|
          row[:addr][input["addr"]] = input["addr"]
          if input["addr"] == address
            recv = "N"
          end
        end
        
        tx['vout'].each do |out|
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
    end
    
    def bitcoind_send_tx(tx_hex, network = :bitcoin)
      
      remote = execute_remote_command('sendrawtransaction ' + tx_hex, network)
      
      #res = JSON.parse(remote)

      mess = 'Unknown'
      stat = 'Unknown'
      tx_hash = 'Unknown'
      
      ret = "{\"status\":\"#{stat}\",\"data\":\"#{tx_hash}\",\"code\":200,\"message\":\"#{mess}\"}"	
      return JSON.parse(ret)	
    end

    def bitcoind_get_balance(address, network = :bitcoin)
      
      if cache_read(network.to_s + ' ' + address) == nil
      
        bal = execute_remote_command('getallbalance ' + address + ' 0', network)
        
        cache_write(network.to_s + ' ' + address, bal.to_f, BALANCE_CACHE_FOR)
      end
      
      bal = cache_read(network.to_s + ' ' + address)
      if bal.class == Fixnum
        bal = bal.to_f
      end
      return bal
        
    end

    def bitcoind_get_all_balances(addresses, network = :bitcoin)
      
      
      # if first address is missing get them all.
      commands  = []
      if cache_read(network.to_s + ' ' + addresses[0]) == nil
        addresses.each do |address|
          commands << 'getallbalance ' + address + ' 0'
        end
        balances = OnChain::BlockChain.execute_remote_command(commands, :zclassic)
        
        index = 0
        balances.each_line do |line|
          cache_write(network.to_s + ' ' + addresses[index], line.to_f, BALANCE_CACHE_FOR)
          index = index + 1
        end
      end
      
      addresses.each do |address|
        bitcoind_get_balance(address, network)
      end
    end

    def bitcoind_get_unspent_outs(address, network = :bitcoin)
        
      result = execute_remote_command('listallunspent ' + address + ' 1 0', network)
      
      json = JSON.parse result
      
      unspent = []
      
      json.each do |data|
        line = []
        line << data['txid']
        line << data['vout']
        line << data['scriptPubKey']['hex']
        line << (data['amount'].to_f * 100000000).to_i
        unspent << line
      end
      
      return unspent
    end

    def bitcoind_get_transaction(txhash, network = :bitcoin)
      return execute_remote_command('getrawtransaction ' + txhash, network)
    end
    
    # Run the command via ssh. For this to work you need
    # to create the follwing ENV vars.
    def execute_remote_command(commands, network)

      host = ENV[network.to_s.upcase + '_HOST']
      username = ENV[network.to_s.upcase + '_USER']
      password = ENV[network.to_s.upcase + '_PASSWORD']
      prefix = ENV[network.to_s.upcase + '_CLI_CMD'] 

      stdout  = ""
      stderr = ""
      begin
        Net::SSH.start(host, username, 
          :password => password,
          :auth_methods => [ 'password' ],
          :number_of_password_prompts => 0)  do |ssh|
          
          if ! commands.is_a?(Array)
            commands = [commands]
          end
          
          commands.each do |command|
            ssh.exec! prefix + ' '+ command do |channel, stream, data|
              stdout << data if stream == :stdout
              stderr << data if stream == :stderr
            end
          end
        end
      rescue Timeout::Error
        return "{ 'error':'Timed out' }"
      rescue Errno::EHOSTUNREACH
        return "{ 'error':'Host unreachable' }"
      rescue Errno::ECONNREFUSED
        return "{ 'error':'Connection refused }"
      rescue Net::SSH::AuthenticationFailed
        return "{ 'error':'Authentication failure' }"
      end
      
      return stdout.chomp
    end
    
  end
end
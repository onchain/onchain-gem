require 'httparty'

class OnChain::Sweeper
  class << self
    
    # Turn a bunch of master keys into a redemption scriopt
    # i.e. derive the path.
    def multi_sig_address_from_mpks(mpks, path)
      
      rs = generate_redemption_script_from_mpks(mpks, path)
      
      return generate_address_of_redemption_script(rs)
    end
    
    def generate_redemption_script_from_mpks(mpks, path)
      
      addresses = []
      mpks.each do |mpk|
        master = MoneyTree::Node.from_serialized_address(mpk)
        m = master.node_for_path(path)
        addresses << m.public_key.to_hex
      end
      
      return generate_redemption_script(addresses)
    end

    def generate_redemption_script(addresses)
    
      rs = (80 + addresses.length).to_s(16) 
    
      addresses.each do |address|
        rs = rs + (address.length / 2).to_s(16)
        rs = rs + address
      end
    
      rs = rs + (80 + addresses.length).to_s(16) 
    
      rs = rs + 'ae'
    
      return rs
    end
  
    def generate_address_of_redemption_script(redemption_script)
      hash160 = Bitcoin.hash160(redemption_script)
    
      return Bitcoin.hash160_to_p2sh_address(hash160)
    end
    
    def get_block_height
      return Chain.get_latest_block["height"].to_i
    end
    
    # With a bunch of HD wallet paths, build a transaction
    # That pays all the coins to a certain address
    def sweep(mpks, path, limit, last_block_checked)
      
      block_height_now = get_block_height
      
      to_sweep = {}
      # Get all the addresses we are interested in.
      for i in 0..limit do
        r = path.sub('#{index}', i.to_s)
        a = multi_sig_address_from_mpks(mpks, r)
        # store address as lookup for path.
        to_sweep[a] = r
      end
      
      incoming_coins = []
      
      to_sweep.each do |address, path|
        
        txs = Chain.get_address_transactions(address)
        
        txs.each do |tx|
          
          block_height = tx["block_height"].to_i 
          if block_height > last_block_checked
            
            tx["outputs"].each do |output|
              output["addresses"].each do |address|
                if to_sweep[address] != nil
                  incoming_coins << [address, 
                    to_sweep[address], 
                    output["value"], 
                    output["transaction_hash"], 
                    output["output_index"], 
                    output["script"]]
                end
              end
            end
            
          else
            break
          end
          
        end
      end
      return incoming_coins, block_height_now
    end

    def create_payment_tx_from_sweep(incoming, destination_address, mpks)
        
      tx = Bitcoin::Protocol::Tx.new
      total_amount = 0
        
      incoming.each do |output|
        
        txin = Bitcoin::Protocol::TxIn.new
        
        rs = generate_redemption_script_from_mpks(mpks, output[1])

        txin.prev_out = OnChain.hex_to_bin(output[3]).reverse
        txin.prev_out_index = output[4]
        txin.script = OnChain.hex_to_bin(rs)
    
        tx.add_in(txin)
        
        total_amount = total_amount + output[2].to_i
        
      end
      
      total_amount = total_amount - 10000
      
      if total_amount < 0
        return "Not enough coins to create a transaction."
      end
      
      # Add an output and we're done.
      txout = Bitcoin::Protocol::TxOut.new(total_amount, 
        Bitcoin::Script.to_address_script(destination_address))
  
      tx.add_out(txout)
      
      paths = incoming.map { |i| i[1] }
      
      return OnChain.bin_to_hex(tx.to_payload), paths
    end
    
    def post_tx_for_signing(tx_hex, paths)
      
      meta = ''
      if paths != nil
        paths.each do |path|
          meta = meta + path
        end
      end
      
      return HTTParty.post('https://onchain.herokuapp.com/api/v1/transaction', 
        :body => { :tx => tx_hex, 
        :meta_data => meta,
        :user_email => ENV['ONCHAIN_EMAIL'],
        :user_token => ENV['ONCHAIN_TOKEN'] }) 
    end
    
  end
end

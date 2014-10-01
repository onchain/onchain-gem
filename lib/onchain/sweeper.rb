class OnChain
  class << self
    
    
    # With a bunch of HD wallet paths, build a transaction
    # That pays all the coins to a certain address
    def sweep(paths, mpk, destination_address)
      
      master = MoneyTree::Node.from_serialized_address(mpk)
      
      new_tx = build_tx do |t|
        
      
      paths.each do |path|
        address = master.node_for_path(path).to_address
      
        unspent = get_unspent_outs(address)
      

        # add the input you picked out earlier
        t.input do |i|
          i.prev_out prev_tx
          i.prev_out_index prev_out_index
          i.signature_key key
        end

        # add an output that sends some bitcoins to another address
        t.output do |o|
          o.value 50000000 # 0.5 BTC in satoshis
          o.script {|s| s.recipient "mugwYJ1sKyr8EDDgXtoh8sdDQuNWKYNf88" }
        end

        # add another output spending the remaining amount back to yourself
        # if you want to pay a tx fee, reduce the value of this output accordingly
        # if you want to keep your financial history private, use a different address
        t.output do |o|
          o.value 49000000 # 0.49 BTC, leave 0.01 BTC as fee
          o.script {|s| s.recipient key.addr }
        end
      end
    end
  end
end

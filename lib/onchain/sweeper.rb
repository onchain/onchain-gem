class OnChain
  class << self
    
    # With a bunch of HD wallet paths, build a transaction
    # That pays all the coins to a certain address
    def sweep(paths, mpk, destination_address)
      
      master = MoneyTree::Node.from_serialized_address(mpk)
      
      paths.each do |path|
        address = master.node_for_path(path).to_address
        puts address
      end
    end
  end
end

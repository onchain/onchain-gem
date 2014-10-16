require 'spec_helper'

describe OnChain do

  # Take 3 private keys
  # Generate a fund
  # Can we then generate addresses down the chain
  # Can we create a TX and sign it ?
  # Do we get the same addresses for keys dereived from MPK as redemption script ?
  it "should give me public keys for a redemption script" do
    
    #OnChain::Sweeper.multi_sig_node_for_path(REDEMPTION_SCRIPT_WITH_BALANCE)
    
    node1 = MoneyTree::Node.from_serialized_address(MPKP1)
    node2 = MoneyTree::Node.from_serialized_address(MPKP2)
    node3 = MoneyTree::Node.from_serialized_address(MPKP3)
    puts node1.node_for_path("m/12").public_key.to_hex
    puts node2.public_key.to_hex
    puts node3.public_key.to_hex
    
    puts node1.node_for_path("m/12").to_address
    
    pk = MoneyTree::PublicKey.new(node1.node_for_path("m/12").public_key.to_hex)
    
    # Reconstruct node from a hex public key
    m = MoneyTree::Node.new(:public_key => pk)
    puts m.public_key.to_hex
    puts m.to_address
    
    # Convert public adrress to something we can use in redemption script.
    
  end
  
  it "should sweep up coins" do
    OnChain::Sweeper.sweep(['m/4', 'm/0'], MPK, '')
  end
end
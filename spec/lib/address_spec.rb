require 'spec_helper'

describe OnChain do
  
  it "should generate a valid bitcoin cash transaction." do
  
    address, priv = OnChain::Address.generate_address_pair(:bitcoin)
    
    puts address
  end

end
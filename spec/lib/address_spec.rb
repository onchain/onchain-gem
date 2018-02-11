require 'spec_helper'

describe OnChain do
  
  it "should generate a valid bitcoin cash transaction." do
  
    address, priv = OnChain::Address.generate_address_pair(:bitcoin)
    
    expect(address[0]).to eq('1')
    
    OnChain::Address.valid_address?(address[0], :bitcoin)
  end

end
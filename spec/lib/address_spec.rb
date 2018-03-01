require 'spec_helper'

describe OnChain do
  
  it "should generate a valid bitcoin cash transaction." do
  
    address, priv = OnChain::Address.generate_address_pair(:bitcoin)
    
    expect(address[0]).to eq('1')
  
    address, priv = OnChain::Address.generate_address_pair(:zcash)
    
    expect(address[0]).to eq('t')
    
    OnChain::Address.valid_address?(address[0], :zcash)
  end
  
  it "should generate a validate addresses by network." do
    
    valid = OnChain::Address.valid_address?(
      '1KuiMQyVSmMraPFiC1FV3H9uHZUgFFwzgb', :bitcoin)
      
    expect(valid).to eq(true)
    
    valid = OnChain::Address.valid_address?(
      '1KuiMQyVSmMraPFiC1FV3H9uHZUgFFwzgb', :zcash)
      
    expect(valid).to eq(false)
    
    valid = OnChain::Address.valid_address?(
      't1boiJuMXRrUsSgd14bPVshihk5GSCpp37U', :zcash)
      
    expect(valid).to eq(true)
    
    # Try a multi sig address
    valid = OnChain::Address.valid_address?(
      '2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca', :testnet3)
      
    expect(valid).to eq(true)
    
  end

end
require 'spec_helper'

describe OnChain do
  
  it "should generate a valid addresses for diffrent networks." do
  
    address, priv = OnChain::Address.generate_address_pair(:bitcoin)
    
    expect(address[0]).to eq('1')
  
    address, priv = OnChain::Address.generate_address_pair(:zcash)
    
    expect(address[0]).to eq('t')
    
    OnChain::Address.valid_address?(address[0], :zcash)
  end
  
  it "should generate addresses form pub keys" do
  
    pubhex = '0428a450cfd9cc029658a7588d6bd515201d6231275b5431b0a6fc420606b0fecd34d3b804335c64f8fcb481eadccc8cb85078f2a0d27f0c86748f3d832c894a2d'
  
    expect(OnChain::Address.address_from_pub_hex(pubhex)).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
  
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
    
    # Try ethereum
    valid = OnChain::Address.valid_address?(
      '0xCB53ab94D84d6b2368013b47B002Bb31Bb36110e', :ethereum)
      
    expect(valid).to eq(true)
    
  end

end
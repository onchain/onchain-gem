require 'spec_helper'

describe OnChain do
  
  it "should give me a status" do
    
    status = OnChain::BlockChain.status
    
    expect(status.include?('Up')).to eq(true)
    
  end
  
end
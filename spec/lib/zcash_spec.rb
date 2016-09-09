require 'spec_helper'

describe OnChain do
  
  it "should give me a balance for a zcash testnet address" do
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :zcash_testnet)
    
    expect(bal1).to eq(0.0)
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    
    expect(bal1).to eq(0.216)
    
  end
  
end
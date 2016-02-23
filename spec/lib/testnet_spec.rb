require 'spec_helper'

describe OnChain do
  
  it "should give me a balance for a testnet address" do
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.001)
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8')
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.0)
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :bitcoin)
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.0)
    
  end
  
end
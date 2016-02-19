require 'spec_helper'

describe OnChain do
  
  it "should give me a balance for a testnet address" do
    
    OnChain.network = :testnet3
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8')
    
    expect(bal1).to eq(0.001)
    
  end
  
end
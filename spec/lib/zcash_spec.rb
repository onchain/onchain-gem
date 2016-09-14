require 'spec_helper'

describe OnChain do
  
  it "should give me a balance for a zcash testnet address" do
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :zcash_testnet)
    
    expect(bal1).to eq(0.0)
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    
    expect(bal1).to eq(0.216)
    
  end
  
  it "should cache the addresses" do
    
    addresses = ['myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8']
    
    bal1 = OnChain::BlockChain.get_balance_satoshi(addresses[0], :zcash_testnet)
    
    expect(bal1).to eq(21600000)
    
    OnChain::BlockChain.get_all_balances(addresses, :zcash_testnet)
    
  end
  
end
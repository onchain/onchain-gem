require 'spec_helper'

describe OnChain do
  
  it "should give me a balance for a testnet address" do
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.216)
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8')
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.0)
    
    bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :bitcoin)
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.0)
    
  end
  
  it "should give me the unspent outs" do
    
    out1 = OnChain::BlockChain.get_unspent_outs('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    
    expect(out1.count).to eq(4)
  end
  
  it "should create a single address transaction" do
    
    
    tx, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
      'myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', 
      'mx97L7gTbERp8B7EK7Bk8R7bgnq6zUKAgY', 4000000, 
      0.01, 'mkk7dRJz4288ux6kLmFi1w6GcHjJowtFc8', 40000, :testnet3)
      
    expect(tx).to eq('010000000172c9c589bb26fe8dcf2f29c562cbc807c6819ae1015c1aa4898ca6209218d2c3010000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88acffffffff0300093d00000000001976a914b6588798023037135a20583ce2c6610e36c6ead888ac30750000000000001976a9143955d3f58ee2d7b941ff7583de109da70d1b8a6288ac60541900000000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac00000000')
    
  end
  
end
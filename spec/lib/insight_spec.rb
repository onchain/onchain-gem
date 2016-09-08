require 'spec_helper'

describe OnChain do
  
  it "should give me a balance for a testnet address" do
    
    bal1 = OnChain::BlockChain.insight_get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
    
    expect(bal1).to eq(0.216)
    
  end
  
  it "should give me the unspent outs" do
    
    out1 = OnChain::BlockChain.insight_get_unspent_outs('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
    
    expect(out1.count).to eq(4)
    
    expect(out1[1][0]).to eq('c3d2189220a68c89a41a5c01e19a81c607c8cb62c5292fcf8dfe26bb89c5c972')
    expect(out1[1][1]).to eq(1)
    expect(out1[1][2]).to eq('76a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac')
    expect(out1[1][3]).to eq(5700000)
    
    expect(out1[3][0]).to eq('93c8e1d06de7a95cacfaa8b9ba2e541d344523761f6818587ccf391493808712')
    expect(out1[3][1]).to eq(0)
    expect(out1[3][2]).to eq('76a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac')
    expect(out1[3][3]).to eq(100000)
  end
  
  it "should give me a history for an address" do
  
    hist = OnChain::BlockChain.insight_address_history('2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca', :testnet3)
    
    expect(hist.length).to eq(3)  
    
    expect(hist[0][:hash]).to eq('bbcf34ada24a9b0276ea04733c3551b09aff6606d256cb415abf80bf32c9fb85')
    expect(hist[0][:time]).to eq(1473081774)
    expect(hist[0][:total]).to eq(0.001)
    
    expect(hist[1][:addr]['2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca']).to eq('2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca')
    
    expect(hist[2][:recv]).to eq('Y')
     
  end
  
  it "should bring back a raw transaction in hex" do
    tx =  OnChain::BlockChain.insight_get_transaction('93c8e1d06de7a95cacfaa8b9ba2e541d344523761f6818587ccf391493808712', :testnet3)
    
    expect(tx).to eq('010000000101ee9e72ac53c71265056f9678a698913c0f07de17ee98b93a03234d7ae6c638000000006a47304402205a1aa8ef7fb07f4878cbe0103163b37bbf8a5c5df2109d9029788b36c056030d02201d64d8f079c1091e3904230b172377d67d2e462eaf9a4d1f3496cd333bdf700e01210203fd215615e20b1c50c4ccae39623dec86b064723ab14657a46f93389f77873bffffffff02a0860100000000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac58060600000000001976a914b6588798023037135a20583ce2c6610e36c6ead888ac00000000')
  end
  
end
require 'spec_helper'

describe OnChain do

  
  it "should store stuff in the cache" do
    
    OnChain::BlockChain.cache_write('test-the-cache', 'down', 60)
    
    expect(OnChain::BlockChain.cache_read('test-the-cache')).to eq('down')
  end
  
  it "should let me temporarily switch off a service" do
    
    suppliers = OnChain::BlockChain.get_available_suppliers()
    
    expect(suppliers.count).to be > 1
    
    OnChain::BlockChain.cache_write('blockinfo', 'down', 60)
    
    suppliers2 = OnChain::BlockChain.get_available_suppliers()
    
    expect(suppliers.count).to be > suppliers2.count
  end
  
  it "Should have same balance for blockinfo and blockr" do
    
    OnChain::BlockChain.cache_write('blockinfo', 'down', 60)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', nil)
      
    suppliers = OnChain::BlockChain.get_available_suppliers()
    
    expect(suppliers.count).to eq(1)
    
    bal1 = OnChain::BlockChain.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', 'down', 60)
      
    suppliers = OnChain::BlockChain.get_available_suppliers()
    
    expect(suppliers.count).to eq(1)
    expect(suppliers[0].to_s).to eq('blockinfo')
    
    bal2 = OnChain::BlockChain.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(bal1).to eq(bal2)
    
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', nil)
    OnChain::BlockChain.cache_write('blockr', nil)
    
  end
  
  it "Should have same unpsent outs blockinfo and blockr" do
    
    OnChain::BlockChain.cache_write('blockinfo', 'down', 60)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', nil)
      
    suppliers = OnChain::BlockChain.get_available_suppliers()
    
    expect(suppliers.count).to eq(1)
    
    out1 = OnChain::BlockChain.get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', 'down', 60)
      
    suppliers = OnChain::BlockChain.get_available_suppliers()
    
    expect(suppliers.count).to eq(1)
    expect(suppliers[0].to_s).to eq('blockinfo')
    
    out2 = OnChain::BlockChain.get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    out1.sort! { |x,y| y[0] <=> x[0] }
    out2.sort! { |x,y| y[0] <=> x[0] }
    
    expect(out1.count).to eq(out2.count)
    
    expect(out1[0][0]).to eq(out2[0][0])
    expect(out1[0][1]).to eq(out2[0][1])
    expect(out1[0][2]).to eq(out2[0][2])
    expect(out1[0][3]).to eq(out2[0][3])
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', nil)
    OnChain::BlockChain.cache_write('blockr', nil)
    
  end
  
  it "Should get me a list of transactions" do
    
    txs = OnChain::BlockChain.get_transactions('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(txs.size).to eq(2)
    
    expect(txs[0][0]).to eq('2009d4382d593d08842ad40bdf515446c4cd57c3e79489fb286a4c95c580e2a5')
    expect(txs[0][1]).to eq(1000000)
    
  end
end

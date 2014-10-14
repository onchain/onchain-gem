require 'spec_helper'

describe OnChain do
  
  it "should store stuff in the cache" do
    
    OnChain::BlockChain.cache_write('test-the-cache', 'down', 60)
    
    expect(OnChain::BlockChain.cache_read('test-the-cache')).to eq('down')
  end
  
  it "should give me a balance from chain.com" do
    
    bal1 = OnChain::BlockChain.chaincom_get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(bal1).to eq(0.02)
  end
  
  it "should give unspent outs from chain.com" do
    
    outs1 = OnChain::BlockChain.chaincom_get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(outs1.count).to eq(2)
    
    outs2 = OnChain::BlockChain.blockr_get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(outs2.count).to eq(2)
    
    
    outs1.sort! { |x,y| y[0] <=> x[0] }
    outs2.sort! { |x,y| y[0] <=> x[0] }
    
    expect(outs1.count).to eq(outs2.count)
    
    expect(outs1[0][0]).to eq(outs2[0][0])
    expect(outs1[0][1]).to eq(outs2[0][1])
    expect(outs1[0][2]).to eq(outs2[0][2])
    expect(outs1[0][3]).to eq(outs2[0][3])
  end
  
  it "should let me temporarily switch off a service" do
    
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance')
    
    expect(suppliers.count).to be > 1
    
    OnChain::BlockChain.cache_write('blockinfo', 'down', 60)
    
    suppliers2 = OnChain::BlockChain.get_available_suppliers('get_balance')
    
    expect(suppliers.count).to be > suppliers2.count
  end
  
  it "should not use blockchain.info as a push_tx supplier" do
    
    suppliers = OnChain::BlockChain.get_available_suppliers('push_tx')
    
    expect(suppliers.count).to eq(2)
    expect(suppliers[0]).to eq(:chaincom)
  end
  
  it "Should have same balance for blockinfo and blockr" do
    
    OnChain::BlockChain.cache_write('blockinfo', 'down', 60)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', nil)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance')
    
    expect(suppliers.count).to eq(1)
    
    bal1 = OnChain::BlockChain.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', 'down', 60)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance')
    
    expect(suppliers.count).to eq(1)
    expect(suppliers[0].to_s).to eq('blockinfo')
    
    bal2 = OnChain::BlockChain.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(bal1).to eq(bal2)
    expect(bal1.is_a? Float).to eq(true)
    expect(bal2.is_a? Float).to eq(true)
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', nil)
    OnChain::BlockChain.cache_write('blockr', nil)
    
  end
  
  it "Should have same unpsent outs blockinfo and blockr" do
    
    OnChain::BlockChain.cache_write('blockinfo', 'down', 60)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', nil)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance')
    
    expect(suppliers.count).to eq(1)
    
    out1 = OnChain::BlockChain.get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    OnChain::BlockChain.cache_write('blockinfo', nil)
    OnChain::BlockChain.cache_write('chaincom', 'down', 60)
    OnChain::BlockChain.cache_write('blockr', 'down', 60)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance')
    
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
    
    # This is wrong, probably needs to add every output int he transaction
    # so we see how much the address really got
    txs = OnChain::BlockChain.get_transactions('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(txs.size).to eq(2)
    
    expect(txs[0][0]).to eq('2009d4382d593d08842ad40bdf515446c4cd57c3e79489fb286a4c95c580e2a5')
    expect(txs[0][1]).to eq(1000000)
    
  end
  
  it "should try to push a tx" do
    
    res1 = OnChain::BlockChain.chaincom_send_tx('010000000193c642b373f0f202e292bd17588999b6a908dd4e4f8e55a9bbc507bab7d5935d00000000255121033cd4640df2a12dee1e74a649b05b698df30ea731cfd8056b33bcc66e419c91fc51aeffffffff02102700000000000017a9141e95aa85aec95ceb33250b1c9f445cc7b0341c9487409c00000000000017a914a69b6e946be609cc7c24f1b7d0b9e120a921915c8700000000')
    
    expect(res1["status"]).to eq("failure")
    
    res2 = OnChain::BlockChain.blockr_send_tx('010000000193c642b373f0f202e292bd17588999b6a908dd4e4f8e55a9bbc507bab7d5935d00000000255121033cd4640df2a12dee1e74a649b05b698df30ea731cfd8056b33bcc66e419c91fc51aeffffffff02102700000000000017a9141e95aa85aec95ceb33250b1c9f445cc7b0341c9487409c00000000000017a914a69b6e946be609cc7c24f1b7d0b9e120a921915c8700000000')
    
    expect(res2["status"]).to eq("failure")
  end
  
  it "should add addresses in bulk into the cache" do
    OnChain::BlockChain.cache_write('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW', nil)
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to eq(nil)
    
    OnChain::BlockChain.chaincom_get_all_balances(['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'])
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to_not eq(nil)
    

    OnChain::BlockChain.cache_write('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW', nil)
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to eq(nil)
    
    OnChain::BlockChain.blockinfo_get_all_balances(['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'])
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to_not eq(nil)
    


    OnChain::BlockChain.cache_write('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW', nil)
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to eq(nil)
    
    OnChain::BlockChain.blockr_get_all_balances(['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'])
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to_not eq(nil)
  end
  
  it "should give me an address history" do
    
    hist = OnChain::BlockChain.blockinfo_address_history('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    puts hist
    
    
    hist = OnChain::BlockChain.chaincom_address_history('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    puts hist
  end
end

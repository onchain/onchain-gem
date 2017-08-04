require 'spec_helper'

describe OnChain do
  
  before(:each) do
    @blockinfo = OnChain::BlockChaininfo.new
    @insight = OnChain::Insight.new('https://insight.bitpay.com/api/')
    @blockr = OnChain::Blockr.new('http://btc.blockr.io/api/v1/')
  end
  
  it "Add the number of confirmations to address history" do
    
    test =  @blockinfo.address_history('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(test[0][:block_height]).to be > 0
    
  end
  
  it "should store stuff in the cache" do
    
    OnChain::BlockChain.cache_write('test-the-cache', 'down', 60)
    
    expect(OnChain::BlockChain.cache_read('test-the-cache')).to eq('down')
  end
  
  it "should let me temporarily switch off a service" do
    
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance', :bitcoin)
    
    expect(suppliers.count).to be > 1
    
    OnChain::BlockChain.cache_write(@blockinfo.url, 'down', 60)
    
    suppliers2 = OnChain::BlockChain.get_available_suppliers('get_balance', :bitcoin)
    
    expect(suppliers.count).to be > suppliers2.count
  end
  
  it "should not use blockchain.info as a push_tx supplier" do
    
    suppliers = OnChain::BlockChain.get_available_suppliers('send_tx', :bitcoin)
    
    expect(suppliers[0].url).not_to eq(@blockinfo.url)
    expect(suppliers[1].url).not_to eq(@blockinfo.url)
  end
  
  it "Should have same balance for blockinfo and blockr" do
    
    OnChain::BlockChain.cache_write(@blockinfo.url, 'down', 60)
    OnChain::BlockChain.cache_write(@insight.url, 'down', 60)
    OnChain::BlockChain.cache_write(@blockr.url, nil)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance', :bitcoin)
    
    expect(suppliers.count).to eq(1)
    
    bal1 = @blockinfo.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    OnChain::BlockChain.cache_write(@blockinfo.url, nil)
    OnChain::BlockChain.cache_write(@insight.url, 'down', 60)
    OnChain::BlockChain.cache_write(@blockr.url, 'down', 60)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance', :bitcoin)
    
    expect(suppliers.count).to eq(1)
    expect(suppliers[0].url).to eq(@blockinfo.url)
    
    bal2 = @blockinfo.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(bal1).to eq(bal2)
    expect(bal1.is_a? Float).to eq(true)
    expect(bal2.is_a? Float).to eq(true)
    
    OnChain::BlockChain.cache_write(@blockinfo.url, nil)
    OnChain::BlockChain.cache_write(@insight.url, nil)
    OnChain::BlockChain.cache_write(@blockr.url, nil)
    
  end
  
  it "Should have same unpsent outs blockinfo and blockr" do
    
    OnChain::BlockChain.cache_write(@blockinfo.url, 'down', 60)
    OnChain::BlockChain.cache_write(@insight.url, 'down', 60)
    OnChain::BlockChain.cache_write(@blockr.url, nil)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance', :bitcoin)
    
    expect(suppliers.count).to eq(1)
    
    out1 = @blockinfo.get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    OnChain::BlockChain.cache_write(@blockinfo.url, nil)
    OnChain::BlockChain.cache_write(@insight.url, 'down', 60)
    OnChain::BlockChain.cache_write(@blockr.url, 'down', 60)
      
    suppliers = OnChain::BlockChain.get_available_suppliers('get_balance', :bitcoin)
    
    expect(suppliers.count).to eq(1)
    expect(suppliers[0].url).to eq(@blockinfo.url)
    
    out2 = @blockinfo.get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    out1.sort! { |x,y| y[0] <=> x[0] }
    out2.sort! { |x,y| y[0] <=> x[0] }
    
    expect(out1.count).to eq(out2.count)
    
    expect(out1[0][0]).to eq(out2[0][0])
    expect(out1[0][1]).to eq(out2[0][1])
    expect(out1[0][2]).to eq(out2[0][2])
    expect(out1[0][3]).to eq(out2[0][3])
    
    OnChain::BlockChain.cache_write(@blockinfo.url, nil)
    OnChain::BlockChain.cache_write(@insight.url, nil)
    OnChain::BlockChain.cache_write(@blockr.url, nil)
    
  end
  
  #it "Should get me a list of transactions" do
  #  
  #  # This is wrong, probably needs to add every output int he transaction
  #  # so we see how much the address really got
  #  txs = @blockr.get_transactions('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
  #  
  #  expect(txs.size).to eq(2)
  #  
  #  expect(txs[0][0]).to eq('2009d4382d593d08842ad40bdf515446c4cd57c3e79489fb286a4c95c580e2a5')
  #  expect(txs[0][1]).to eq(0.01)
  #  
  #end
  
  it "should try to push a tx" do
    
    res2 = @blockr.send_tx('010000000193c642b373f0f202e292bd17588999b6a908dd4e4f8e55a9bbc507bab7d5935d00000000255121033cd4640df2a12dee1e74a649b05b698df30ea731cfd8056b33bcc66e419c91fc51aeffffffff02102700000000000017a9141e95aa85aec95ceb33250b1c9f445cc7b0341c9487409c00000000000017a914a69b6e946be609cc7c24f1b7d0b9e120a921915c8700000000')
    
    expect(res2["status"]).to eq("failure")
  end
  
  it "should add addresses in bulk into the cache" do

    OnChain::BlockChain.cache_write('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW', nil)
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to eq(nil)
    
    @blockinfo.get_all_balances(['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'])
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to_not eq(nil)
    


    OnChain::BlockChain.cache_write('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW', nil)
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to eq(nil)
    
    @blockr.get_all_balances(['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'])
    
    expect(OnChain::BlockChain.cache_read('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')).to_not eq(nil)
  end
  
  it "should give me an address history" do
    
    hist = @blockinfo.address_history('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    expect(hist.length).to eq(6)   
  end
  
  it "should have same number of outs" do
    
    outs1 = @blockinfo.get_unspent_outs('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    expect(outs1.length).to eq(2)   
     
    outs3 = @blockinfo.get_unspent_outs('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    expect(outs3.length).to eq(2)   
  end
  
  it "should give me histories for addresses" do
    
    hist = OnChain::BlockChain.get_history_for_addresses(
      ['3Q7iW72L3ySno4CMCDpRSzkzEH6iGEta8E', 
      '36yWeF77VXNMbTLGEFbYJfAcV6qgv24jEi', 
      '34rNLSmvXiHqQAGJfAeGF7bxoYj8KYfLvU', 
      '3PK6greGvd4uHHJ7ArUxa3Pwby9UZsb5B8', 
      '3B6hK8RJ9mvEiYLJDsvE3rzQAcZxjuYxnq', 
      '3AqKf1RCiqnnLKsph4rTxcPerNTYQUWPYQ', 
      '38SZMDLhJRiHsDKjxydeFT8HyA6wbHcHVd', 
      '3NWnAx1bD3PgoHZ7pJo6emMJn71Ee2vSpB', 
      '38BqfF4LUgpbvoYbGpyYAw44qrpS841GA1'])
      
    expect(hist.count).to eq(101)
  end
  
  it "should give me unspent for an amount" do
    
    addresses = ['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW']
    
    unspents, indexes, change = OnChain::BlockChain.get_unspent_for_amount(addresses, 10001, :bitcoin)
    
    expect(unspents.length).to eq(1)  
    expect(change).to eq(89999) 
  end
  
  it "should give me more balance info" do
    
    @blockinfo.get_address_info('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    
  end
  
  it "should have transactions in the history" do
    hist = OnChain::BlockChain.address_history('1JCLW7cvVv2aHvcCUc4284unoaKXciftzW')
    
    expect(hist[0][:hash]).to eq('4b7bcee97331ac178dc5d1b3613e082f1e4fca4fae4562066bada61ac622fe0a')
  end
end

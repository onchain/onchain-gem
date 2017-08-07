require 'spec_helper'

describe OnChain do
  
  before(:each) do
    @bitcoin_cash = OnChain::BlockChain::COINS[:bitcoin_cash][:apis].first[:provider]
    @bitcoin = OnChain::BlockChain::COINS[:bitcoin][:apis].first[:provider]
  end
  
  it "should match the old blockchain for coins that haven't moved." do
      
    # This is an old no lobger used address so the results should
    # be the same form both networks.
    
    # Insight API
    test1 =  @bitcoin_cash.address_history('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    # Blockchain API
    test2 =  @bitcoin.address_history('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(test1[0][:outs].length).to eq(3)
    expect(test2[0][:outs].length).to eq(3)
    
  end
  
  it "balances should be different for addresses active on bitcoin." do
      
    # This is an old no lobger used address so the results should
    # be the same form both networks.
    
    # Insight API
    test1 =  @bitcoin_cash.get_balance('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
    
    # Blockchain API
    test2 =  @bitcoin.get_balance('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
    
    
    expect(test1).not_to eq(test2)
    
  end
  
end
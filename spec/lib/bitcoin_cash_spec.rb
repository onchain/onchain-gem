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
  
  it "try and send a transaction" do
      
    # This is actually a bitcoin testnet transaction
    res = @bitcoin_cash.send_tx('010000000101ee9e72ac53c71265056f9678a698913c0f07de17ee98b93a03234d7ae6c638000000006a47304402205a1aa8ef7fb07f4878cbe0103163b37bbf8a5c5df2109d9029788b36c056030d02201d64d8f079c1091e3904230b172377d67d2e462eaf9a4d1f3496cd333bdf700e01210203fd215615e20b1c50c4ccae39623dec86b064723ab14657a46f93389f77873bffffffff02a0860100000000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac58060600000000001976a914b6588798023037135a20583ce2c6610e36c6ead888ac00000000')

    expect(res["data"]).to eq('Missing inputs. Code:-25')
  end
  
end
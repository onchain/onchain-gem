require 'spec_helper'

describe OnChain do
  
  before(:each) do
    @bitcoin_cash = OnChain::BlockChain::COINS[:bitcoin_cash][:apis].first[:provider]
    @bitcoin = OnChain::BlockChain::COINS[:bitcoin][:apis].first[:provider]
  end
  
  subject(:the_subject) do |example|
     "bitcoin_cash_spec/" + example.description
  end
  
  it "should generate a valid bitcoin cash transaction." do
      
    VCR.use_cassette(the_subject) do
      
      tx, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
        '19W97njDjfQzEULoGLhr5cT5FS48ihVXWk', 
        '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 1000000, 
        0, '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 10000, :bitcoin_cash)
        
      expect(tx).to eq('0100000001a1800209a311c3ef7eab782cf1ca6c8f664bf048d54b1c5df8edaa0799451ff3020000001976a9145d43d84d26447d78a5f78ecb28e5a5d1b6c4927b88acffffffff0140420f00000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000')
      expect(inputs_to_sign[0]['19W97njDjfQzEULoGLhr5cT5FS48ihVXWk']['hash']).to eq('476169f577ec342aaed96c1d328a2038dc1548635068fcb34389db0c4595517b')
      
    end
    
  end
  
  it "should match the old blockchain for coins that haven't moved." do
      
    VCR.use_cassette(the_subject) do
      # This is an old no lobger used address so the results should
      # be the same form both networks.
      
      # Insight API
      test1 =  @bitcoin_cash.address_history('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
      
      # Blockchain API
      test2 =  @bitcoin.address_history('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
      
      expect(test1[0][:outs].length).to eq(3)
      expect(test2[0][:outs].length).to eq(3)
    end
    
  end
  
  it "balances should be different for addresses active on bitcoin." do
    
    VCR.use_cassette(the_subject) do  
      # This is an old no lobger used address so the results should
      # be the same form both networks.
      
      # Insight API
      test1 =  @bitcoin_cash.get_balance('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
      
      # Blockchain API
      test2 =  @bitcoin.get_balance('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
      
      
      expect(test1).not_to eq(test2)
    end
    
  end
  
  it "try and send a transaction" do
      
    VCR.use_cassette(the_subject) do  
      # This is actually a bitcoin testnet transaction
      res = @bitcoin_cash.send_tx('010000000101ee9e72ac53c71265056f9678a698913c0f07de17ee98b93a03234d7ae6c638000000006a47304402205a1aa8ef7fb07f4878cbe0103163b37bbf8a5c5df2109d9029788b36c056030d02201d64d8f079c1091e3904230b172377d67d2e462eaf9a4d1f3496cd333bdf700e01210203fd215615e20b1c50c4ccae39623dec86b064723ab14657a46f93389f77873bffffffff02a0860100000000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac58060600000000001976a914b6588798023037135a20583ce2c6610e36c6ead888ac00000000')
  
      expect(res["data"]).to eq('Missing inputs. Code:-25')
    end
  end
  
end
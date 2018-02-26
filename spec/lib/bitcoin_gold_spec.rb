require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "bitcoin_gold_spec/" + example.description
  end
  
  it "should generate the correct bitcoin gold address format" do
    
    
    address = OnChain::Address.generate_address_pair(:bitcoin_gold)
    
    expect(address[0][0]).to eq('G')
    
  end
  
  it "should give me a balance for a bitcoin gold address" do
    
    VCR.use_cassette(the_subject) do
      
      bal = OnChain::BlockChain.get_balance('GK18bp4UzC6wqYKKNLkaJ3hzQazTc3TWBw', :bitcoin_gold)
      expect(bal).to be > 0
      
    end
    
  end 
  
  it "should modify the sighashes 24 MSB's with the fork ID" do
    
    VCR.use_cassette(the_subject) do
      
      tx, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
        'GWViUY2b3HAYWY9BbeGeFjc6rKdrBffzHa', 
        'GeZZjk2yPWwXrNvJMSAbHa5MWDhvGzkcqd', 1000000, 
        0, 'GeZZjk2yPWwXrNvJMSAbHa5MWDhvGzkcqd', 10000, :bitcoin_gold)
        
      #expect(tx).to eq('0100000001a1800209a311c3ef7eab782cf1ca6c8f664bf048d54b1c5df8edaa0799451ff3020000001976a9145d43d84d26447d78a5f78ecb28e5a5d1b6c4927b88acffffffff0140420f00000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000')
      expect(inputs_to_sign[0]['1Deo4Qhe4RZFS4qtfhcXpyGCw9r18b8pSj']['hash']).
        to eq('400c62afea55afc671969f08d46a30c5a5bf183c2a356433317e2649011469d1')
      
    end
  end
  
end
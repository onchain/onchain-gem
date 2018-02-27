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
        
      expect(tx).to eq('010000000153a20637bf666c28ceeb8142de0de72da5833de04223e1a51e83cc499ec35957000000001976a9148ac7591107aec68c282488cd74096014108844dd88acffffffff0240420f00000000001976a914e342b95d1a6391d1ecc04fe31d5e9655984ab8b888ac1655b749000000001976a9148ac7591107aec68c282488cd74096014108844dd88ac00000000')
      expect(inputs_to_sign[0]['1Deo4Qhe4RZFS4qtfhcXpyGCw9r18b8pSj']['hash']).
        to eq('51a1b3d0ef25e51490c83bd94e7e7d151bcc8dd5f7c349f376d64d01de8e02d3')
      
    end
  end
  
end
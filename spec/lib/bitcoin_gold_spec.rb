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
  
end
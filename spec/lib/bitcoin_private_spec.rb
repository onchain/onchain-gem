require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "bitcoin_private_spec/" + example.description
  end
  
  it "should be able to retrieve a balance." do
    
    VCR.use_cassette(the_subject) do  
      
      # Insight API
      test1 =  OnChain::BlockChain.get_balance(
        'b1FXnBitEhacvi8urCJ4BHRX4eQDgBNjSym', :bitcoin_private)
      
      
      expect(test1).to eq(0.01)
    end
    
  end
  
  it "should get unspent outs." do
      
    #VCR.use_cassette(the_subject) do
       
    #end
    
  end
end
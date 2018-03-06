require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "bitcoin_private_spec/" + example.description
  end
  
  it "should be able to retrieve a balance." do
    
    VCR.use_cassette(the_subject) do  
      
      # Insight API
      test1 =  OnChain::BlockChain.get_balance(
        'b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N', :bitcoin_private)
      
      
      expect(test1).to eq(32.66721836)
    end
    
  end
  
  it "should create and sign a valid bitcoin private transaction." do
    
    wif = 'L1BaRvRHhVVtq3AAWRCdaa1QJFHFpoQXXiyoLWoBurf7UznREdNw'
    
    public_key = OnChain::Address.address_from_wif(wif, :bitcoin_private)
      
    expect(public_key).to eq('b17e5xisoAzgwr5ZQ7k9h7NQyKgSnhm7WeC')
    #VCR.use_cassette(the_subject) do
       
    #end
    
  end
end
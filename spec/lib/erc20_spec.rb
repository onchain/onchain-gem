require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "erc20_spec/" + example.description
  end
  
  it "should get a balance for a token." do
      
    VCR.use_cassette(the_subject) do
        
      contract = '0x1175a66a5c3343bbf06aa818bb482ddec30858e0'
      address = '0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6'
      
      bal = OnChain::BlockChain.get_token_balance(contract, address, :ethereum)
      
      expect(bal).to eq(150)
      
    end
    
  end
end
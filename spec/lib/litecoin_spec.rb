require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
   "litecoin_spec/" +  example.description
  end
  
  it "should generate the correct litecoin address format" do
    
    
    address = OnChain::Address.generate_address_pair(:litecoin)
    
    expect(address[0][0]).to eq('L')
    
  end
  
  it "should give me a balance for a litecoin address" do
    
    VCR.use_cassette(the_subject) do
      
      bal = OnChain::BlockChain.get_balance('LUbnkC2CwM3QtELafmaARDMnrfmdHAKjLP', :litecoin)
      expect(bal).to eq(0)
      
    end
    
  end
  
end
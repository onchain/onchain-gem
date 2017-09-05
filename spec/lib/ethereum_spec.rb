require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should give me a balance for an ethereum address" do
    
    VCR.use_cassette(the_subject) do
      bal1 = OnChain::BlockChain.get_balance('0x4b1306936CFFAF74dC3132f4749E2EA6BE8a1C53', :ethereum)
      
      expect(bal1).to eq(1.1014122225579598)
    end
    
  end
end
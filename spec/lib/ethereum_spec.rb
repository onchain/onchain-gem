require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should give me a balance for an ethereum address" do
    
    VCR.use_cassette(the_subject) do
      bal1 = OnChain::BlockChain.get_balance('0x4b1306936CFFAF74dC3132f4749E2EA6BE8a1C53', :ethereum)
      
      expect(bal1).to eq(0.000605552557959792)
      
      bal1 = OnChain::BlockChain.get_balance('0x891f0139e4cb8afbf5847ba6260a4214c64c3658', :ethereum)
      
      expect(bal1).to eq(0)
      
    end
    
  end
  
  it "should cache a list of balances for ethereum" do
    
    VCR.use_cassette(the_subject) do
    
      addresses = ['0x4b1306936CFFAF74dC3132f4749E2EA6BE8a1C53']    
    
      OnChain::BlockChain.get_all_balances(addresses, :ethereum)
      
      bal = OnChain::BlockChain.cache_read(addresses[0])
      
      expect(bal).to eq(0.000605552557959792)
      
      OnChain::BlockChain.get_all_balances([], :ethereum)
    end
    
  end
end
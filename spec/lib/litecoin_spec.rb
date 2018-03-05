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
  
  it "should give me a litecoin address history" do
    
    VCR.use_cassette(the_subject) do
      
      test = [{:hash=>"8a2b0a4fd4e8519f325298ce286e28551ffe5acf5d118803e23f185bafdf6d64", 
        :time=>1520032335, 
        :addr=>{"LMhb7STao6j1GNztHC3TwjKwEGbPp7p7cj"=>"LMhb7STao6j1GNztHC3TwjKwEGbPp7p7cj"}, 
        :outs=>{"LbzPdP41rXBD46WjRzLUk23F228G5LyEeJ"=>"LbzPdP41rXBD46WjRzLUk23F228G5LyEeJ"}, 
        :total=>0.05142032, :recv=>"Y"}]
      
      history = OnChain::BlockChain.address_history('LbzPdP41rXBD46WjRzLUk23F228G5LyEeJ', :litecoin)
      expect(history.to_json).to eq(test.to_json)
      
    end
    
  end
  
end
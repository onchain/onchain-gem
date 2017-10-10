require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should get the min for an exchange" do
    
    VCR.use_cassette(the_subject) do
      result_json = OnChain::Exchange.get_min_amount('btc', 'eth')
      
      expect(result_json['result']).to_not be_nil
      
      puts result_json['result'][0]['minAmount']
      
      expect(result_json['result'][0]['minAmount'].to_f).to be > 0.0
    end
    
  end
  
  it "should get estimate from exchange" do
    
    VCR.use_cassette(the_subject) do
      
      result_json = OnChain::Exchange.get_estimate('btc', 'eth', 1.0)
      
      expect(result_json['result']).to_not be_nil
      
      expect(result_json['result'].to_f).to be > 0.0
      
    end
    
  end
  
  it "should generate an exchange address" do
    
    VCR.use_cassette(the_subject) do
      
      result_json = OnChain::Exchange.generate_address(
        'btc', 'eth', "0x891f0139e4cb8afbf5847ba6260a4214c64c3658")
        
      puts result_json
      
      address = result_json['result']['address']
      expect(result_json['result']['address']).to_not be_nil
      
      puts address
      
      #expect(result_json['result'].to_f).to be > 0.0
      
      result_json = OnChain::Exchange.get_transactions("eth", address)
      
      puts result_json
    end
    
  end
end
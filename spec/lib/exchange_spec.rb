require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should get the min for an exchange" do
    
    VCR.use_cassette(the_subject) do
      result_json = OnChain::Exchange.get_min_amount(:bitcoin, :ethereum)
      
      expect(result_json['result']).to_not be_nil
      
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
end
require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should get the min for an exchange" do
    
   puts OnChain::Exchange.get_min_amount(:bitcoin)
    
  end
end
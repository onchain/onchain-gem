require 'spec_helper'

describe OnChain do
  
  it "should get the price of Bitocin" do
    
    puts OnChain::ExchangeRate.exchange_rate(:USD).to_f
    
  end

end
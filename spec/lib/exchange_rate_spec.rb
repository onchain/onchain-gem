require 'spec_helper'

describe OnChain do
  
  it "should get the price of Bitcoin" do
    
    rate = OnChain::ExchangeRate.bitcoin_exchange_rate(:USD).to_f
    
    expect(rate).to be > 0.1
  end
  
  it "should get the price of zclassic" do
    
    rate = OnChain::ExchangeRate.alt_exchange_rate(:zclassic)
    
    expect(rate).to be > 0.001
    
  end

end
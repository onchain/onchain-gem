require 'spec_helper'

describe OnChain do
  
  it "should turn a bunch of mpks and a path into an address" do
    addr = OnChain::Sweeper.multi_sig_address_from_mpks([MPK1, MPK2, MPK3], "m/12")
    
    expect(addr).to eq('3L6PVTfYJ1XEnUF3pTYRidcQnMbpwYhdMo')
    
    addr = OnChain::Sweeper.multi_sig_address_from_mpks([MPK1, MPK2, MPK3], "m/14")
    
    expect(addr).to eq('349JjM6ToV5KEsXTxqcJAwEvLn6fgcYQQJ')
    
  end
  
  it "should sweep up coins" do
    OnChain::Sweeper.sweep(['m/4', 'm/0'], MPK, '')
  end
end
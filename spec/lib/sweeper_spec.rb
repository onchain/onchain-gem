require 'spec_helper'

describe OnChain do
  
  it "should turn a bunch of mpks and a path into an address" do
    addr = OnChain::Sweeper.multi_sig_address_from_mpks([MPK1, MPK2, MPK3], "m/12")
    
    expect(addr).to eq('3L6PVTfYJ1XEnUF3pTYRidcQnMbpwYhdMo')
    
    addr = OnChain::Sweeper.multi_sig_address_from_mpks([MPK1, MPK2, MPK3], "m/14")
    
    expect(addr).to eq('349JjM6ToV5KEsXTxqcJAwEvLn6fgcYQQJ')
    
  end
  
  it "should sweep up coins given a bunch of mpks" do

    latest_block = OnChain::Sweeper.get_block_height
    
    # MPKS, pattern, max_int
    # search through 20 addresses.
    OnChain::Sweeper.sweep([MPK1, MPK2, MPK3], 'm/#{index}', 5, latest_block - 1)
    
    # From the last block to the latest get each block.
    # Get each transaxction
    # Does the transaction contain one of our addresses.
    # If so log it.
    
  end
end
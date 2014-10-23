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
    incoming, block = OnChain::Sweeper.sweep([MPK1, MPK2, MPK3], 'm/#{index}', 2, 325718)
    
    expect(incoming.length).to eq(0)
    
    # From the last block to the latest get each block.
    # Get each transaxction
    # Does the transaction contain one of our addresses.
    # If so log it.
    incoming, block = OnChain::Sweeper.sweep([BITMPKP], 'm/#{index}', 2, 325718)
    
    expect(incoming.length).to eq(1)
    expect(incoming[0][2] == 50000)

    incoming, block = OnChain::Sweeper.sweep([BITMPKP], 'm/#{index}', 2, 325719)
    
    expect(incoming.length).to eq(0)
    
  end
  
  it "should create a transaction form a sweep." do

    incoming, block = OnChain::Sweeper.sweep([BITMPKP], 'm/#{index}', 2, 325718)
    
    tx, paths = OnChain::Sweeper.create_payment_tx_from_sweep(incoming, "3GzGsZ5zFWsFR5LU8TYntptkZqvZrPWzw5", [BITMPKP])
    
    puts paths
    puts tx
    
  end
  
  it "should generate a correct redemption script." do

    IOCPUB = "03ed9c19aa7363c81bd803da4abe1b2221e2716c3b465f40c99b544f9493848496"
    
    pub = "03efae664511239eb463924ba073ff7f249485372b5706de05c75a97fe68ed3954"
    
    rs = OnChain::Sweeper.generate_redemption_script([pub, IOCPUB])
    
    expect(rs).to eq('522103efae664511239eb463924ba073ff7f249485372b5706de05c75a97fe68ed39542103ed9c19aa7363c81bd803da4abe1b2221e2716c3b465f40c99b544f949384849652ae')
  end
end
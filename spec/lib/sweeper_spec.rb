require 'spec_helper'

describe OnChain do
  
  it "should turn a bunch of mpks and a path into an address" do
    addr = OnChain::Sweeper.multi_sig_address_from_mpks(3, [MPK1, MPK2, MPK3], "m/12")
    
    expect(addr).to eq('3L6PVTfYJ1XEnUF3pTYRidcQnMbpwYhdMo')
    
    addr = OnChain::Sweeper.multi_sig_address_from_mpks(3, [MPK1, MPK2, MPK3], "m/14")
    
    expect(addr).to eq('349JjM6ToV5KEsXTxqcJAwEvLn6fgcYQQJ')
    
    addr = OnChain::Sweeper.multi_sig_address_from_mpks(1, [BITMPKP], "m/2")
    
    expect(addr).to eq('32bbCLMbHe9GPV7Ymmj2CKVZWYhQ5ZNCAu')
    
  end
  
  it "should generate the correct redemptions script" do
    rs = OnChain::Sweeper.generate_redemption_script_from_mpks(1, [BITMPKP], "m/2")
    
    expect(rs).to eq('5121024869c2dbd85fd7af9d833309ba6f3de04415d6f4b842c9c84dc695b18d099a6851ae')
  end
  
  it "should sweep up coins given a bunch of mpks" do

    latest_block = OnChain::Sweeper.get_block_height
    
    # MPKS, pattern, max_int
    # search through 20 addresses.
    incoming, block = OnChain::Sweeper.sweep(3, [MPK1, MPK2, MPK3], 'm/#{index}', 2, 325718)
    
    expect(incoming.length).to eq(0)
    
    # From the last block to the latest get each block.
    # Get each transaxction
    # Does the transaction contain one of our addresses.
    # If so log it.
    incoming, block = OnChain::Sweeper.sweep(1, [BITMPKP], 'm/#{index}', 2, 325718)
    
    expect(incoming.length).to eq(1)
    expect(incoming[0][2] == 50000)

    incoming, block = OnChain::Sweeper.sweep(1, [BITMPKP], 'm/#{index}', 2, 325719)
    
    expect(incoming.length).to eq(0)
    
  end
  
  # Compare against BitcoinJS fiddle. http://jsfiddle.net/t78vmyL0/
  it "should create a transaction form a sweep." do

    incoming, block = OnChain::Sweeper.sweep(1, [BITMPKP], 'm/#{index}', 2, 325718)
    
    tx, paths = OnChain::Sweeper.create_payment_tx_from_sweep(1, incoming, "3GzGsZ5zFWsFR5LU8TYntptkZqvZrPWzw5", [BITMPKP])
    
    raw_tx = Bitcoin::Protocol::Tx.new OnChain.hex_to_bin(tx)
    expect(raw_tx.in.size).to eq(1)
    
    # Does our tx match the one I created on fiddle ?
    expect(tx).to eq('0100000001dee4e391ee41a0f3dc3f458a524115ad50a2f4d057fd11278709cdbc805b471700000000255121024869c2dbd85fd7af9d833309ba6f3de04415d6f4b842c9c84dc695b18d099a6851aeffffffff01409c00000000000017a914a7cd6fbb008d8de20be48f932dca9a4ccce357c08700000000')
    
  end
  
  it "should generate a correct redemption script." do

    IOCPUB = "03ed9c19aa7363c81bd803da4abe1b2221e2716c3b465f40c99b544f9493848496"
    
    pub = "03efae664511239eb463924ba073ff7f249485372b5706de05c75a97fe68ed3954"
    
    rs = OnChain::Sweeper.generate_redemption_script(2, [pub, IOCPUB])
    
    expect(rs).to eq('522103efae664511239eb463924ba073ff7f249485372b5706de05c75a97fe68ed39542103ed9c19aa7363c81bd803da4abe1b2221e2716c3b465f40c99b544f949384849652ae')
  end
  
  it "should post a tx to onchain." do

    tx = 'rubbish'
    paths = ['m/1']
    
    ENV['ONCHAIN_TOKEN'] = 'y1sy5ZG'
    ENV['ONCHAIN_EMAIL'] = 'test@test.com'
    
    begin
      r = OnChain::Sweeper.post_tx_for_signing(tx, paths)
      return true
    rescue => e
    end
  end
end
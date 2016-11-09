require 'spec_helper'

describe OnChain do
  
  it "should getinfo" do
      
      puts  OnChain::BlockChain.execute_remote_command('getinfo', :zclassic)
      
  end
  
  it "should give me a history for a zcash address" do
    
    hist = OnChain::BlockChain.address_history('t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx', :zclassic)
    
    puts hist
    
    expect(hist.length).to be > 0
  end
  
  it "should give me a balance for a zcash address" do
    
    bal = OnChain::BlockChain.get_balance('t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx', :zclassic)
    
    expect(bal.to_i).to eq(90000000)
  end
  

end
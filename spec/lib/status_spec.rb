require 'spec_helper'

describe OnChain do
  
  it "should give me a status" do
    
    begin
      OnChain::BlockChain.get_address_info('1STRonGxnFTeJiA7pgyneKknR29Aw')
    rescue
    end
  
    status = OnChain::BlockChain.status
    
    puts status
    
    expect(status.include?('Up')).to eq(true)
    
  end
  
end
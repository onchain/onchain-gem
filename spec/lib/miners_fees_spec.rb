require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
   "miners_fees_spec/" +  example.description
  end
  
  it "get recommended transaction fee" do
    VCR.use_cassette(the_subject) do
      fee = OnChain::Transaction.get_recommended_tx_fee["fastestFee"]
      
      expect(fee).to be > 0
    end
  end
  
  it "should estimate transaction sizes" do
    VCR.use_cassette(the_subject) do
      orig_addr = '13H8HWUgyaeMXJoDnKeUFMcXLJbCQ7s7V5'
      
      OnChain::Transaction.estimate_transaction_size([orig_addr], 0.38 * 100_000_000)
    end
  end
  
  it "should calculate the miners fee" do
    
    VCR.use_cassette(the_subject) do
      orig_addr = '1HMTY59ZaVB9L4rh7PjMjEca2fiT1TucGH'
      
      fee = OnChain::Transaction.calculate_miners_fee([orig_addr], 1000000)
      
      expect(fee).to be > 1000
    end
  end
  
end
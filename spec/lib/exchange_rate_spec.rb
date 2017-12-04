require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    "exchange_rate_spec/" + example.description
  end
  
  it "should get a satoshi balance" do
    
    VCR.use_cassette(the_subject) do
      addresses = ["3CwaQwoCt5YYCaG1X9jFFVHhWbiRKJDGDu", "3HvXbNNJMsDt7SwGPqgCD7g1uDxVQy5Fcg", "36345AA9227D782WQtWoNNVQYzKULFn8KG", "3MzQgNvinm9V9ymFRUVgin8y3wCM9NtMD1", "3BVwu413mXo98qcCWSGXe1tiJrDP6tXs3h", "3Gj5WHpUySzCPdjh66AA7yciLEVWCJQxSF", "328i4UGraZBfW1HSxYzgk129HVSkTLxh3o", "3MACWQP2Ty8jW1aQM4QjMVAmgRq7X5PdYB", "37RQ2brqCAziHDkUchVShGmKcCfTcZPmPD", "3K96nc3Eyp8JgLG1DWpXxCEXqE2JAvfYgC", "39uAMnzeNqLb3y7Y8Fy1xAGLyDguzQvBSw"]
      
      OnChain::BlockChain.get_all_balances(addresses, :bitcoin)
    end
  end
  
  it "should get the price of Bitcoin" do
    
    VCR.use_cassette(the_subject) do
      rate = OnChain::ExchangeRate.exchange_rate(:EUR).to_f
      rate = OnChain::ExchangeRate.exchange_rate(:GBP).to_f
      rate = OnChain::ExchangeRate.exchange_rate(:USD).to_f
      
      expect(rate).to be > 3000
    end
  end
  
  it "should get the price of zclassic" do
    
    VCR.use_cassette(the_subject) do
      rate = OnChain::ExchangeRate.exchange_rate(:USD, :zclassic)
      
      expect(rate).to be > 2.1
    end
    
  end
  
  it "should get the price of etheum" do
    
    VCR.use_cassette(the_subject) do
      rate = OnChain::ExchangeRate.exchange_rate(:USD, :ethereum)
      
      expect(rate).to be > 2.1
    end
    
  end

end
require 'spec_helper'

describe OnChain do
  
  it "should get a satoshi balance" do
    
    addresses = ["3CwaQwoCt5YYCaG1X9jFFVHhWbiRKJDGDu", "3HvXbNNJMsDt7SwGPqgCD7g1uDxVQy5Fcg", "36345AA9227D782WQtWoNNVQYzKULFn8KG", "3MzQgNvinm9V9ymFRUVgin8y3wCM9NtMD1", "3BVwu413mXo98qcCWSGXe1tiJrDP6tXs3h", "3Gj5WHpUySzCPdjh66AA7yciLEVWCJQxSF", "328i4UGraZBfW1HSxYzgk129HVSkTLxh3o", "3MACWQP2Ty8jW1aQM4QjMVAmgRq7X5PdYB", "37RQ2brqCAziHDkUchVShGmKcCfTcZPmPD", "3K96nc3Eyp8JgLG1DWpXxCEXqE2JAvfYgC", "39uAMnzeNqLb3y7Y8Fy1xAGLyDguzQvBSw"]
    
    OnChain::BlockChain.get_all_balances(addresses, :bitcoin)
  end
  
  it "should get the price of Bitcoin" do
    
    rate = OnChain::ExchangeRate.bitcoin_exchange_rate(:EUR).to_f
    rate = OnChain::ExchangeRate.bitcoin_exchange_rate(:GBP).to_f
    rate = OnChain::ExchangeRate.bitcoin_exchange_rate(:USD).to_f
    
    expect(rate).to be > 0.1
  end
  
  it "should get the price of zclassic" do
    
    rate = OnChain::ExchangeRate.alt_exchange_rate(:zclassic)
    
    expect(rate).to be > 0.0000001
    
  end

end
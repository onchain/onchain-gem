require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "erc20_spec/" + example.description
  end
  
  it "should get a balance for a token." do
      
    VCR.use_cassette(the_subject) do
        
      contract = '0x1175a66a5c3343bbf06aa818bb482ddec30858e0'
      address = '0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6'
      
      bal = OnChain::BlockChain.get_token_balance(contract, address, 18, :ethereum)
      
      expect(bal).to eq(150)
      
    end
    
  end
  
  it "should transfer a token." do
    
    VCR.use_cassette(the_subject) do
      
      hex, inputs_to_sign = OnChain::Ethereum.create_token_transfer(
        '0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6', # from me
        '0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6', # to someone
        '0x1175a66a5c3343bbf06aa818bb482ddec30858e0', # this is the contract
        1.0, 18) # Amount and decimal places.
        
      expect(hex).to eq('0xf869808504a817c800827530941175a66a5c3343bbf06aa818bb482ddec30858e080b844a9059cbb00000000000000000000000046fc2341dc457ba023cf6d60cb0729e5928a81e60000000000000000000000000000000000000000000000000de0b6b3a7640000808080')
      
    end
    
  end
  
  it "should finalize a token transfer." do
    
    VCR.use_cassette(the_subject) do
      
      r = '0xbc8914339995ccc9787a2a34090345b349f18cd2a73ae5644996cbb9b5270396'
      s = '0x11b79f9bc9c95fae0a97bb12be5af1770b370d5498d7f8d7b19489cd922cd67f'
      v = 28
      
      tx = OnChain::Ethereum.finish_token_transfer(
        '0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6', # from me
        '0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6', # to someone
        '0x1175a66a5c3343bbf06aa818bb482ddec30858e0', # this is the contract
        1, 18,
        r, s, v) # Amount and decimal places.
        
      expect(tx.hex).to eq('0xf8a9808504a817c8008275309446fc2341dc457ba023cf6d60cb0729e5928a81e680b844a9059cbb00000000000000000000000046fc2341dc457ba023cf6d60cb0729e5928a81e60000000000000000000000000000000000000000000000000de0b6b3a76400001ca0bc8914339995ccc9787a2a34090345b349f18cd2a73ae5644996cbb9b5270396a011b79f9bc9c95fae0a97bb12be5af1770b370d5498d7f8d7b19489cd922cd67f')
      
    end
    
  end
  
  it "should finalize a token transfer." do
    
    tx = "0xf869808504a817c800827530941175a66a5c3343bbf06aa818bb482ddec30858e080b844a9059cbb000000000000000000000000d61c98f88d0a6156e9a7775abf9c1c751658a04500000000000000000000000000000000000000000000000000000000000000b4808080"
    
    details = OnChain::Transaction.interrogate_token(tx, 18)
    
    puts details
    
  end
end
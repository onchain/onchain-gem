require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should post an ethereum transaction" do
    VCR.use_cassette(the_subject) do
      tx_hex = '0xf86c018504a817c800832fefd894891f0139e4cb8afbf5847ba6260a4214c64c365887038d7ea4c68000001ca05bbf5f7377478cd3547d3a7aa78005675678fb97af7d2211a9f072ec31da2646a00f5d8eaa449311c107b9f9d5cdcb92210461b194f5d3bc0e561e9879e84a4583'
      
      ret = OnChain::BlockChain.send_tx(tx_hex, :ethereum)
      
      expect(ret[:message]).to eq('Success')
    end
  end
  
  it "should create an default fees for an ethereum transaction" do
    
    VCR.use_cassette(the_subject) do
      
      amount_to_send = (0.001 * 1_000_000_000_000_000_000).to_i
      
      tx_hex, hashes_to_sign = OnChain::Ethereum.create_single_address_transaction(
        '0x58382493d401d91af0c6a375af9e949d6e106448', 
        '0x891f0139e4cb8afbf5847ba6260a4214c64c3658', 
        amount_to_send)
        
      expect(tx_hex).to eq('0xeb018504a817c80082753094891f0139e4cb8afbf5847ba6260a4214c64c365887038d7ea4c6800000808080')  
      expect(hashes_to_sign[0]['hash']).to eq('292d030db74f996a8b43a9f8722a879657054219f3c343047c9b55c2e775cc06')  
   
    end
       
  end
  
  it "should create an ethereum transaction" do
    
    VCR.use_cassette(the_subject) do
      
      amount_to_send = (0.001 * 1_000_000_000_000_000_000).to_i
      
      OnChain::BlockChain.cache_write('0x58382493d401d91af0c6a375af9e949d6e106448nonce', nil)
      
      tx_hex, hashes_to_sign = OnChain::Ethereum.create_single_address_transaction(
        '0x58382493d401d91af0c6a375af9e949d6e106448', 
        '0x891f0139e4cb8afbf5847ba6260a4214c64c3658', 
        amount_to_send, 20_000_000_000, 3_141_592)
        
      expect(tx_hex).to eq('0xec808504a817c800832fefd894891f0139e4cb8afbf5847ba6260a4214c64c365887038d7ea4c6800000808080')  
      
      expect(hashes_to_sign[0]['hash']).to eq('e1d7483d38b0eec8bcc4719af1e1ba6ec592816621b0a48d083e7c8bca3daa14')  
      
      # These were generating by ethereum-util
      r = '0xbc8914339995ccc9787a2a34090345b349f18cd2a73ae5644996cbb9b5270396'
      s = '0x11b79f9bc9c95fae0a97bb12be5af1770b370d5498d7f8d7b19489cd922cd67f'
      v = 28
      
      # Reconstruct it and sign it.
      tx = OnChain::Ethereum.finish_single_address_transaction(
        '0x58382493d401d91af0c6a375af9e949d6e106448', 
        '0x891f0139e4cb8afbf5847ba6260a4214c64c3658', 
        amount_to_send, r, s, v, 20_000_000_000, 3_141_592)
      
      key = Eth::Key.new priv: 'e0f7f55b019272d732a373f8a4855f9ffb5b5abfa6d724e7a78dec136249a6a3'
      expect(key.verify_signature tx.unsigned_encoded, tx.signature).to eq(true)
    end
      
  end
  
  it "should give me a balance for an ethereum address" do
    
    VCR.use_cassette(the_subject) do
      bal1 = OnChain::BlockChain.get_balance('0x58382493d401d91af0c6a375af9e949d6e106448', :ethereum)
      
      expect(bal1).to eq(0.01269626)
      
      bal1 = OnChain::BlockChain.get_balance('0x891f0139e4cb8afbf5847ba6260a4214c64c3658', :ethereum)
      
      expect(bal1).to eq(0)
      
    end
    
  end
  
  it "should give me a nonce for an ethereum address" do
    
    VCR.use_cassette(the_subject) do
      
      OnChain::BlockChain.cache_write('0x58382493d401d91af0c6a375af9e949d6e106448nonce', nil)
      
      nonce = OnChain::BlockChain.get_nonce('0x58382493d401d91af0c6a375af9e949d6e106448', :ethereum)
      
      expect(nonce).to eq(1)
      
    end
    
  end
  
  it "should cache a list of balances for ethereum" do
    
    VCR.use_cassette(the_subject) do
    
      addresses = ['0x58382493d401d91af0c6a375af9e949d6e106448']    
    
      OnChain::BlockChain.get_all_balances(addresses, :ethereum)
      
      bal = OnChain::BlockChain.cache_read(addresses[0] + 'ethereum')
      
      expect(bal).to eq(0.01269626)
      
      OnChain::BlockChain.get_all_balances([], :ethereum)
    end
    
  end
end
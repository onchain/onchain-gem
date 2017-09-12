require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should post an ethereum transaction" do
    VCR.use_cassette(the_subject) do
      tx_hex = '0xf86c018504a817c800832fefd894891f0139e4cb8afbf5847ba6260a4214c64c365887038d7ea4c68000001ca05bbf5f7377478cd3547d3a7aa78005675678fb97af7d2211a9f072ec31da2646a00f5d8eaa449311c107b9f9d5cdcb92210461b194f5d3bc0e561e9879e84a4583'
      
      ret = OnChain::BlockChain.send_tx(tx_hex, :ethereum)
      
      expect(ret[:message]).to eq('Error validating transaction: Transaction adf9b044b7fbe74472e4cb874c474290f7e78660189a4b0d567504e96541f8fb orphaned, missing reference 0000000000000000000000000000000000000000000000000000000000000000.')
    end
  end
  
  it "should create a transaction" do
    
    tx_hex, hashes_to_sign = OnChain::Ethereum.create_single_address_transaction(nil, 
      '0x58382493d401d91af0c6a375af9e949d6e106448', 1000000)
      
    expect(tx_hex).to eq('0xe8018504a817c800832fefd89458382493d401d91af0c6a375af9e949d6e106448830f424000808080')  
    expect(hashes_to_sign[0]['hash']).to eq('4a8ef1d53eb6d76f753229ec5d718812bf1245347f36897c81011e9496ae853b')  
    
    # These were generating by ethereum-util
    r = '0x6c81654c41dfd48447c35a7d685f89f6ae1ccf0c02629ebccfa33663baf3d04e'
    s = '0x77116b84c9a25383f0ca451d274bdd1a53ab86a9e5f3dce3e8f78889ecc9eb0f'
    v = 27
    
    # Reconstruct it and sign it.
    tx = OnChain::Ethereum.finish_single_address_transaction(nil,
      '0x58382493d401d91af0c6a375af9e949d6e106448', 1000000, r, s, v)
    
    key = Eth::Key.new priv: 'e0f7f55b019272d732a373f8a4855f9ffb5b5abfa6d724e7a78dec136249a6a3'
    expect(key.verify_signature tx.unsigned_encoded, tx.signature).to eq(true)
      
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
      
      nonce = OnChain::BlockChain.get_nonce('0x58382493d401d91af0c6a375af9e949d6e106448', :ethereum)
      
      expect(nonce).to eq(0)
      
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
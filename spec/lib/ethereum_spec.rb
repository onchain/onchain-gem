require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
    example.description
  end
  
  it "should create a transaction" do
    
    tx_hex, hash_hex = OnChain::Ethereum.create_single_address_transaction(nil, 
      '0x58382493d401d91af0c6a375af9e949d6e106448', 1000000)
      
    expect(tx_hex).to eq('0xe8018504a817c800832fefd89458382493d401d91af0c6a375af9e949d6e106448830f424000808080')  
    expect(hash_hex).to eq('4a8ef1d53eb6d76f753229ec5d718812bf1245347f36897c81011e9496ae853b')  
    
    # These were generating by ethereum-util
    r = '0x6c81654c41dfd48447c35a7d685f89f6ae1ccf0c02629ebccfa33663baf3d04e'
    s = '0x77116b84c9a25383f0ca451d274bdd1a53ab86a9e5f3dce3e8f78889ecc9eb0f'
    v = 27
    
    # Reconstruct it and sign it.
    tx = Eth::Tx.new({
      data: '00',
      gas_limit: 3_141_592,
      gas_price: 20_000_000_000,
      nonce: 1,
      to: '0x58382493d401d91af0c6a375af9e949d6e106448',
      value: 1000000,
      v: v,
      s: s.to_i(16),
      r: r.to_i(16)
    })
    
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
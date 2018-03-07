require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "bitcoin_gold_spec/" + example.description
  end
  
  it "should send out this transaction" do
    
    VCR.use_cassette(the_subject) do
      amount =  (0.005 * 100000000).to_i
      
      fee_satoshi = (0.004 * 100_000_000).to_i
      
      one_percent = (amount * 0.01).to_i
      
      recipient = 'GPA6kzQKUg5uwB4u84Jq64FLDu7BtqiFYd'
      
      receive_addresses = ["GgM7KG85o2tpHBnq1UgQ3SQe3UL8tv1xUT", "GaXevAX4HwsHJL3ktgEyXgWaJ71o1Vd1bN", "GWSDSsz83BqYnyW57c519aPjHiS3Rgh3ZC", "GRG4QNXbAfwF8g4H396Ta8UQzyMKGxkLAP", "GTdSQ4yU1TE3jpKx7sfJhYJRzkRxUXL5zq", "GfwAxC7DDBMKj7341S7VjZDsKh5Drggh78", "GQQmvzCwboQMTHjWZJt8v54bM7zDpJ6Ztn", "Ggkyg9kK3HA4shRJCCnVYa4p4hUTwkRWsL", "GX4Jhz4VdLKFFGoWL6HdEiYbzXPWYYd1KQ", "GMPhCmCfwTGd1TX1xBEJMeDXps5EcPLu9g", "GQ8zGbgHDRe11budCvuAntbT7hGqVZB6mv"] 
      
      miners_fee = OnChain::Transaction.calculate_miners_fee(receive_addresses,
        amount, :bitcoin_gold)
      
      browser_pub_keys = ["02f82f91a780f3493c891479fc1829b3591938e1bcce0e4fa7d75229115e01fdb5", "03a4aaeba13560cce7913b87158efabbc4a00070060f2202feb02acf920232c194", "03e131d6f9e9f83cfa18de2e89887cc4c829ab99c230bc884c22ddb6ffab19e121", "020a97214f30021fe0f3d1a1c5eae8f1d5a11872494b89bea3253cfd4bd60097bb", "0358d5d72d006117a6d4e10a8fc9b2600d8881052beedadb096c875a2be9812339", "02ed114a08032febfefe4a7c4c6739a8cb4d20b8dd5acfeafa8c30291eef41a99b", "03a631b1fceed4834054902bd0b474536ba23217a3471cbfee07d96dbbb3a70485", "026701c3c5a6d94cc294a889fde91a15f7072ee6b16fd8b76a5e31b6564895387c", "034a01894fd357e07b2e6cc77aad40824cd44b67629396bf9774559c4bfe43655d", "034812c0f84507824e0bd65cf2a9b4709d66faa63c3d6889cdb2f156c5af22cebf", "029af801935696881cfeaf1bd7aecee37c6d661cba0690649166e5b844169de242"]
      
      if one_percent > fee_satoshi
        fee_satoshi = one_percent
      end 
      
      fee_satoshi = fee_satoshi - miners_fee
      
     unsigned_tx, sig_list, total_input_value = 
        OnChain::Transaction.create_transaction_from_public_keys(
          browser_pub_keys, recipient, amount, 
          fee_satoshi, 'GaXevAX4HwsHJL3ktgEyXgWaJ71o1Vd1bN', 
          miners_fee, :bitcoin_gold)
      
      # Do we match the TX created in carbon wallet
      expect(total_input_value).to eq(29099999)
      
      pub_key = browser_pub_keys[0]
      
      expect(sig_list[0][pub_key]['hash']).to eq('da7e96550f14f1d4e42c141e68863b398eb7f5c58f1d9ae432284849621dd45a')
      expect(sig_list[1][pub_key]['hash']).to eq('a6c9c7ad1f42f7f43fae274e3bff8b1c50eb41ff1208ad28bbe742702c172e37')
      
      sig_list[0][pub_key]['sig'] = '30450221009a4cec3b661d9e000409e466985c4fbdea02e604a278586c3eb10831a9ffea9402203e04e4c3f332512924f35c0935b06c377004eb539fad3a27eca2ce969ba8a565'
      sig_list[1][pub_key]['sig'] = '3045022100fbb377ac59d12b360d5eb91ab0a3fe567f4148f6d4027cf17137564d0513569702207443315f987ed1a3ae38fcdeb97d1fad1d5d86aee7e8e2571898baa978cd1e10'
      
      # Are the signatures correct
      verify = Bitcoin.verify_signature([sig_list[0][pub_key]['hash']].pack("H*"), 
          [sig_list[0][pub_key]['sig']].pack("H*"), pub_key)
          
      expect(verify).to eq(true)
      
      verify = Bitcoin.verify_signature([sig_list[1][pub_key]['hash']].pack("H*"), 
          [sig_list[1][pub_key]['sig']].pack("H*"), pub_key)
          
      expect(verify).to eq(true)
      
      # Does it match the one we generated with the front end.
      expect(unsigned_tx).to eq('010000000265ac8882523135c6582b5f188b1fd2612683301de0e78d170bc16496cd7c8f33000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88acffffffffe2c77937fd2cb743edff26d61395b12d92279700aa9c96c1035814380c3b9a68010000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88acffffffff0320a10700000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac58610500000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac3f4cae01000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac00000000')
      
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all]
    
      if Bitcoin::NETWORKS[:bitcoin_gold][:fork_id] != nil
        puts "Using forkid"
        hash_type = hash_type | Bitcoin::Script::SIGHASH_TYPE[:forkid]
      end
    
      signed_payload = OnChain::Transaction.sign_single_signature_transaction(
          unsigned_tx, sig_list, hash_type)
      
      expect(signed_payload).to eq('010000000265ac8882523135c6582b5f188b1fd2612683301de0e78d170bc16496cd7c8f33000000006b4830450221009a4cec3b661d9e000409e466985c4fbdea02e604a278586c3eb10831a9ffea9402203e04e4c3f332512924f35c0935b06c377004eb539fad3a27eca2ce969ba8a565412102f82f91a780f3493c891479fc1829b3591938e1bcce0e4fa7d75229115e01fdb5ffffffffe2c77937fd2cb743edff26d61395b12d92279700aa9c96c1035814380c3b9a68010000006b483045022100fbb377ac59d12b360d5eb91ab0a3fe567f4148f6d4027cf17137564d0513569702207443315f987ed1a3ae38fcdeb97d1fad1d5d86aee7e8e2571898baa978cd1e10412102f82f91a780f3493c891479fc1829b3591938e1bcce0e4fa7d75229115e01fdb5ffffffff0320a10700000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac58610500000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac3f4cae01000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac00000000')
      
      res = OnChain::BlockChain.send_tx(signed_payload, :bitcoin_gold)    
      puts res
    end
    
  end
  
  it "should generate the correct bitcoin gold address format" do
    
    
    address = OnChain::Address.generate_address_pair(:bitcoin_gold)
    
    expect(address[0][0]).to eq('G')
    
  end
  
  it "should give me a balance for a bitcoin gold address" do
    
    VCR.use_cassette(the_subject) do
      
      bal = OnChain::BlockChain.get_balance('GK18bp4UzC6wqYKKNLkaJ3hzQazTc3TWBw', :bitcoin_gold)
      expect(bal).to be > 0
      
    end
    
  end 
  
  it "should modify the sighashes 24 MSB's with the fork ID" do
    
    VCR.use_cassette(the_subject) do
      
      tx, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
        'GWViUY2b3HAYWY9BbeGeFjc6rKdrBffzHa', 
        'GeZZjk2yPWwXrNvJMSAbHa5MWDhvGzkcqd', 1000000, 
        0, 'GeZZjk2yPWwXrNvJMSAbHa5MWDhvGzkcqd', 10000, :bitcoin_gold)
        
      expect(tx).to eq('010000000153a20637bf666c28ceeb8142de0de72da5833de04223e1a51e83cc499ec35957000000001976a9148ac7591107aec68c282488cd74096014108844dd88acffffffff0240420f00000000001976a914e342b95d1a6391d1ecc04fe31d5e9655984ab8b888ac1655b749000000001976a9148ac7591107aec68c282488cd74096014108844dd88ac00000000')
      expect(inputs_to_sign[0]['1Deo4Qhe4RZFS4qtfhcXpyGCw9r18b8pSj']['hash']).
        to eq('51a1b3d0ef25e51490c83bd94e7e7d151bcc8dd5f7c349f376d64d01de8e02d3')
      
    end
  end
  
end
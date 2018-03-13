require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "bitcoin_private_spec/" + example.description
  end
  
  it "should not have the same hashes for 2 inputs" do
  
    VCR.turned_off do
      
      public_key = 'b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N'
    
      stub_request(:get, "https://explorer.btcprivate.org/api/addr/#{public_key}/utxo").
        with(headers: {'Accept'=>'*/*', 
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 
          'Host'=>'explorer.btcprivate.org', 'User-Agent'=>'Ruby'}).
        to_return(status: 200, body: 
          '[{"address":"b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N","txid":"b167a4ee51b48d276f81c257b74312e59f6d2e014cd5e0a045dc3e4e5ab9fa27","vout":2,"scriptPubKey":"76a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac","amount":0.628,"satoshis":62800000,"height":284578,"confirmations":366},{"address":"b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N","txid":"5d0df199aeb0ff93ed2681a46819073688df0eba4d859f08647a8461f0df7ca9","vout":0,"scriptPubKey":"76a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac","amount":30,"satoshis":3000000000,"height":272939,"confirmations":12005},{"address":"b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N","txid":"0b51b283c65d3c4bc453f5e87947d0278c537dd6efda8a44d7a03c55399ee561","vout":0,"scriptPubKey":"76a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac","amount":2,"satoshis":200000000,"height":272938,"confirmations":12006},{"address":"b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N","txid":"00cc6fefe7605596c2447ffe316401e6c7e8b15dbe322d366c29d2db2e8b9902","vout":2,"scriptPubKey":"76a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac","amount":0.01221836,"satoshis":1221836,"height":272851,"confirmations":12093}]', 
          headers: {})
          
      tx_hex, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
        "#{public_key}", 
        'b19nP23vNEyWiyz6B9G5hFnt7w12RAPbsU9', (8.2 * 100_000_000).to_i, 
        17000, 'b19nP23vNEyWiyz6B9G5hFnt7w12RAPbsU9', 300, :bitcoin_private)
          
      #puts tx_hex
      
      #puts
      
      hash1 = inputs_to_sign.first['1PWBu8o8pBHXCiVY5Y2Hcg4k8JYHw5Cdut']['hash']
      hash2 = inputs_to_sign.last['1PWBu8o8pBHXCiVY5Y2Hcg4k8JYHw5Cdut']['hash']
      
      expect(hash1).to eq('35cc246e12b15474a4e473253806a9400cb0340eb11877039f08228932e10932')
      
      expect(hash2).to eq('35cc246e12b15474a4e473253806a9400cb0340eb11877039f08228932e10932')
      
      equal = hash1 == hash2
      
      expect(equal).to be(false)
    end
  
  end
  
  #it "should create a valid payment" do
  #  VCR.turned_off do
  #  
  #    pk = ENV['private_key']
  #    public_key  = OnChain::Address.address_from_wif(pk, :bitcoin_private)
  #    puts "Public Key we are using - #{public_key}\n"
  #    
  #    if ! pk
  #      throw 'Set private key in env'
  #    end
  #    
  #    key = Bitcoin::Key.from_base58 pk
  #    
  #    stub_request(:get, "https://explorer.btcprivate.org/api/addr/#{public_key}/utxo").
  #       with(headers: {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Host'=>'explorer.btcprivate.org', 'User-Agent'=>'Ruby'}).
  #       to_return(status: 200, body: '[{"address":"b1H4VhwWAoVGMqnXM8oqsKK2WzpMGkbRamm","txid":"db832d5b046eb2a297d2f3044c22a891d9c4adb9806396e39e1ec2cf531c0375","vout":0,"scriptPubKey":"76a9148a1dde437f546b20222b4a4434c8b9dd4d8b05ba88ac","amount":0.005,"satoshis":500000,"height":272358,"confirmations":9711},{"address":"b1H4VhwWAoVGMqnXM8oqsKK2WzpMGkbRamm","txid":"9f416e184a3e918e96095f27fbb20452bf4cb113cabd514046cdec43c8acccbc","vout":0,"scriptPubKey":"76a9148a1dde437f546b20222b4a4434c8b9dd4d8b05ba88ac","amount":0.005,"satoshis":500000,"height":272353,"confirmations":9716}]', headers: {})
  #    
  #    tx_hex, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
  #      "#{public_key}", 
  #      'b19nP23vNEyWiyz6B9G5hFnt7w12RAPbsU9', 482699, 
  #      17000, 'b19nP23vNEyWiyz6B9G5hFnt7w12RAPbsU9', 300, :bitcoin_private)
  #      
  #    puts "Unsigned TX\n" + tx_hex
  #    
  #    puts "\nInputs before signing.\n"
  #    
  #    puts inputs_to_sign
  #    
  #    sign_with_eckey(inputs_to_sign, key)
  #    
  #    puts "\nInputs after signing.\n"
  #    
  #    puts inputs_to_sign
  #    
  #    puts "\nSigned? " + OnChain::Transaction.do_we_have_all_the_signatures(inputs_to_sign).to_s
  #    
  #    hash = inputs_to_sign.first[inputs_to_sign.first.keys.first]["hash"]
  #    sig = inputs_to_sign.first[inputs_to_sign.first.keys.first]["sig"]
  #    
  #    
  #    # Verify signature
  #    verified = Bitcoin.verify_signature([hash].pack("H*"), 
  #        [sig].pack("H*"), key.pub)
  #        
  #    puts "Verified? " + verified.to_s
  #    
  #  
  #    hash_type = Bitcoin::Script::SIGHASH_TYPE[:all]
  #    hash_type = hash_type | Bitcoin::Script::SIGHASH_TYPE[:forkid]
  #    
  #    signed_tx = OnChain::Transaction.sign_transaction(
  #      tx_hex, inputs_to_sign, key.pub, hash_type)
  #      
  #    puts
  #    puts "Signed TX"
  #    puts signed_tx
  #        
  #  end
  #end
  
  
  def sign_with_eckey(inputs_to_sign, pk)
    
    pub_hex = pk.addr
    
    inputs_to_sign.each do |input|
      
      if input[pub_hex] != nil
        
        hash_to_sign = input[pub_hex]["hash"]
        
        sig =  OnChain.bin_to_hex(pk.sign(OnChain.hex_to_bin(hash_to_sign)))
        
        input[pub_hex]["sig"] = sig
      end
    end
  end
  
  it "should be able to retrieve a balance." do
    
    VCR.use_cassette(the_subject) do  
      
      # Insight API
      test1 =  OnChain::BlockChain.get_balance(
        'b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N', :bitcoin_private)
      
      
      expect(test1).to eq(32.66721836)
    end
    
  end
  
  it "should create and sign a valid bitcoin private transaction." do
    
    wif = 'L1BaRvRHhVVtq3AAWRCdaa1QJFHFpoQXXiyoLWoBurf7UznREdNw'
    
    public_key = OnChain::Address.address_from_wif(wif, :bitcoin_private)
      
    expect(public_key).to eq('b17e5xisoAzgwr5ZQ7k9h7NQyKgSnhm7WeC')
    #VCR.use_cassette(the_subject) do
       
    #end
    
  end
end
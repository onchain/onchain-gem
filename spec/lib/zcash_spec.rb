require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
   "zcash_spec/" +  example.description
  end
  
  it "should generate the correct address format" do
    
    pk = '92CzBupESg5fmsJJa1PzcLqRwFVaXSMtpgftcWfh75z2FbzRkKK'

    Bitcoin.network = :zcash_testnet
    key = Bitcoin::Key.from_base58(pk)
    
    expect(key.addr).to eq("tmH5vQ1k6JqajN16H5QoFTjddqmSKE7jnMz")

    Bitcoin.network = :zcash
    
    pk = "KyVUtNKYEoDP39iWUUjVQGbPcMDePnWjo1sFocPeqcTyxgmnLCSn"
    
    key = Bitcoin::Key.from_base58(pk)
    
    expect(key.addr).to eq("t1NyDssbvdEaYyRdvNEZCHg7dcCFJQfDQF3")
    
    Bitcoin.network = :bitcoin
    
  end
  
  it "should generate the correct multi sig addresses" do
    
    rs = ["5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102787adcb5648253eaf437f7fa516c4defbfd2f6fea896cfe2ca644330212390d352ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102835743a35a8bd08cc5c2c9a0a814ff331ec5be9c84883eb0e84f700d605ef30152ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103a0b2c4d3286d5ce538c93bb578e8b25f8e685618d6c0304ec6556393ad873b4c52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102536c74016e54a5023160960fa739cadf8f031d78d9cb0ceb7922c174cd4e7c2a52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721032a1f697a7bc0b6feaa036e7f08d2ff7674f9dbc3e17ef930d1f7ec10755bc5f852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721034a502facb54118ed072abab32321665bd3ed609fe2a5f63aa687a8a55205efa852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103c287f5d86aac6156b7368fe3c474cef5d9e27e4a0580b55a822ed83e65c43e9852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103a438065c6dd6c1db7bbd1077828cddb8d1f1322bc21df530214c495d681d19ac52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103bc1ba670f47c239bd567f5ffe733e90250b26d21b5d5f35f9aa119081efd4d8d52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721028bc9fd70333fd6ae9205aed42de5e37ac17b82dc386bdc0d0dec3bca1a28f5c052ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721029770d82c16ef9388620430b14f4c7f078cc456bd5c2c76cb039c9aa67034512d52ae"]
    
    address_version = Bitcoin::NETWORKS[:zcash_testnet][:p2sh_version]
    
    hash = Bitcoin.hash160(rs[0])
    
    address = Bitcoin.encode_address(hash, address_version)
    
    expect(address).to eq("t2BU1ZvXFoLRDFsoKj2Rkdv8zT48ruFuftc")
    
    address_version = Bitcoin::NETWORKS[:zcash][:p2sh_version]
    
    address = Bitcoin.encode_address(hash, address_version)
    
    expect(address).to eq("t3PUpXFR7vsoqiBDaoHRi6HxMLZuh2tnu3C")
    
  end
  
  it "should give me a blance for a zcash address" do
    
    VCR.use_cassette(the_subject) do
      
      bal = OnChain::BlockChain.get_balance('t3PUpXFR7vsoqiBDaoHRi6HxMLZuh2tnu3C', :zcash)
      expect(bal).to eq(0)
      
    end
    
  end
  
  it "should generate an over winter tx" do
    
    VCR.use_cassette(the_subject) do
      pk = "L2ZDeyeJcuqewNwG4VEttFUjLm3tG8cSo13MWPNdHaWfa7oGJrog"
  
      Bitcoin.network = :zcash
      key = Bitcoin::Key.from_base58(pk)
      expect(key.addr).to eq("t1WnesYVsCCh96VorkF3oLaCyiyniNoPdhZ")
      Bitcoin.network = :bitcoin
      
      pub_hex = '02a8c45cc289f1a2707f7df4ca5f12348d56e8f48ee9abe86d3b9213e17922cbc8'
    
      tx, inputs_to_sign = OnChain::Transaction.create_transaction_from_public_keys(
        [pub_hex], 
        't1coURaGEsTgaG6Jp8Y2rA2sUppakecfJKC', 3000000, 
        30000, 't1WnesYVsCCh96VorkF3oLaCyiyniNoPdhZ', 10000, :zcash)
        
      expect(tx).to eq('030000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f306245e06f010000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88acffffffff03c0c62d00000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac30750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88accb6a0700000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac000000000000000000')
      
      the_hash = inputs_to_sign.first[pub_hex]["hash"]
      sig =  OnChain.bin_to_hex(key.sign(OnChain.hex_to_bin(the_hash)))
      
      inputs_to_sign.first[pub_hex]["sig"] = sig
      
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all]
      
      signed_tx = OnChain::Transaction.sign_single_signature_transaction(
        tx, inputs_to_sign, hash_type, :zcash)
        
      res = OnChain::BlockChain.send_tx(signed_tx, :zcash)
      
      puts res
        
    end
  end
  
  it "should create a blake2 (Needs python3 > 3.6)" do
    
    expect(OnChain::blake2b('', 'ZcashPrevoutHash')).to eq('d53a633bbecf82fe9e9484d8a0e727c73bb9e68c96e72dec30144f6a84afa136')
   
    expect(OnChain::blake2b('', 'ZcashSequencHash')).to eq('a5f25f01959361ee6eb56a7401210ee268226f6ce764a4f10b7f29e54db37272')
    
    expect(OnChain::blake2b('8f739811893e0000095200ac6551ac636565b1a45a0805750200025151', 'ZcashOutputsHash')).to eq('ec55f4afc6cebfe1c35bdcded7519ff6efb381ab1d5a8dd0060c13b2a512932b')
    
    expect(OnChain::blake2b('', 'ZcashSigHash')).to eq('a8b7d33290ca936765a88d37c2a8fe739fecc2670df3068082a31209cd311ddd')
    
  end
  
  it "should parse and reproduce a zcash transaction" do
    
    # Test vector 1
    tx_hex = '030000807082c40300028f739811893e0000095200ac6551ac636565b1a45a0805750200025151481cdd86b3cc431800'
    
    tx = Bitcoin::Protocol::Tx.create_from_hex(tx_hex, :zcash)
    
    # hashPrevouts:
    #  BLAKE2b-256('ZcashPrevoutHash', b'')
    # = d53a633bbecf82fe9e9484d8a0e727c73bb9e68c96e72dec30144f6a84afa136
    expect(tx.zcash_prev_out_hash).to eq('d53a633bbecf82fe9e9484d8a0e727c73bb9e68c96e72dec30144f6a84afa136')
    
    # hashSequence:
    #  BLAKE2b-256('ZcashSequencHash', b'')
    # = a5f25f01959361ee6eb56a7401210ee268226f6ce764a4f10b7f29e54db37272
    expect(tx.zcash_sequence_hash).to eq('a5f25f01959361ee6eb56a7401210ee268226f6ce764a4f10b7f29e54db37272')
    
    # hashOutputs:
    #   BLAKE2b-256('ZcashOutputsHash', 8f739811893e0000095200ac6551ac636565b1a45a0805750200025151)
    # = ec55f4afc6cebfe1c35bdcded7519ff6efb381ab1d5a8dd0060c13b2a512932b
    expect(tx.zcash_outputs_hash).to eq('ec55f4afc6cebfe1c35bdcded7519ff6efb381ab1d5a8dd0060c13b2a512932b')
    
    expect(OnChain.bin_to_hex(tx.signature_hash_for_zcash(0, nil, nil, 1, false))).to eq('5f0957950939a65c5a76128eaf552ca8e86066387325bd831f3cd32962ce1a65')
    
    tx_generated = OnChain::bin_to_hex(tx.to_network_payload(:zcash))
    
    expect(tx_generated).to eq(tx_hex)
  end

  it "should parse and reproduce my zcash transaction" do
    tx_hex = '030000807082c4030138e86e187f471ce1ebbaf30463d9995bd56fdd49a25ed5269b148f306245e06f010000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88acffffffff03c0c62d00000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac30750000000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88accb6a0700000000001976a9148da9f29035effc39e4e8f37e82cb8e27fd7ae61c88ac000000000000000000'
  
    tx = Bitcoin::Protocol::Tx.create_from_hex(tx_hex, :zcash)

    tx_generated = OnChain::bin_to_hex(tx.to_network_payload(:zcash))
    
    expect(tx_generated).to eq(tx_hex)

    tx_hex = "030000807082c40301571727cd8cd142a73814ec9b98ee79dff42cc0cdeb797b55678c4039c2d6cffc010000006a47304402202cc010bb764262c1d3a3e9fc67e9c91384e7544ffa3ecb62a0e536958c8806e302205e3d122ecc929f76f51088f26f71e2fcbbcf34fcc6758509031fcf7a775e3be0012102010a560c7325827df0212bca20f5cf6556b1345991b6b64b469c616e758230a5ffffffff02b2b19300000000001976a914c8b56e00740e62449a053c15bdd4809f720b5cb588acd0e0bb01000000001976a914c3df1bbbf84b4f021e0c894b2506ef33f01d2b5b88ac000000009374050000"
  
    tx = Bitcoin::Protocol::Tx.create_from_hex(tx_hex, :zcash)

    tx_generated = OnChain::bin_to_hex(tx.to_network_payload(:zcash))
    
    expect(tx_generated).to eq(tx_hex)
  end
  
  it "should generate another winter tx" do
    
    VCR.use_cassette(the_subject) do
      
      pub_hex = '028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7'
      
      tx, inputs_to_sign = OnChain::Transaction.create_transaction_from_public_keys(
        [pub_hex], 
        't1coURaGEsTgaG6Jp8Y2rA2sUppakecfJKC', 
        100000, 
        400000, 
        't1aZLWNcFHR3apVoMuAPzEjGbdbR2qGfcAw', 
        40000, :zcash)
      
      # This is the same as the onchain.io API generates.  
      expect(tx).to eq('030000807082c40301f293c1b1d289fba09d0eb40a622a69f70f7b0e5bc3c77bca6ff6db543ce0a209010000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388acffffffff03a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac801a0600000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac64952e00000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac000000000000000000')
      
      the_hash = inputs_to_sign.first[pub_hex]["hash"]
      
      expect(the_hash).to eq('4641f0dc37dbf7e6de97d1039e6363a7d1ad560a660b8e826da59e05d87a2725')
      
      # Sig as generated by CW
      sig =  '3045022100d31be9d230442694705cc0ac38189eb2b0cec9fea66b2eef4f5b477e9e35168f0220195b06383bb18faf70c91580116d33105ea7e027a887060046deab6f32470134'
      
      inputs_to_sign.first[pub_hex]["sig"] = sig
      
      hash_type = Bitcoin::Script::SIGHASH_TYPE[:all]
      
      signed_tx = OnChain::Transaction.sign_single_signature_transaction(
        tx, inputs_to_sign, hash_type, :zcash)
        
      # Does it equal the signed transaction we get from CW?
      expect(signed_tx).to eq('030000807082c40301f293c1b1d289fba09d0eb40a622a69f70f7b0e5bc3c77bca6ff6db543ce0a209010000006b483045022100d31be9d230442694705cc0ac38189eb2b0cec9fea66b2eef4f5b477e9e35168f0220195b06383bb18faf70c91580116d33105ea7e027a887060046deab6f324701340121028f883177988f212f2f1b89bc0aa1fb0683899c3665b62167b0daa998018f85d7ffffffff03a0860100000000001976a914cfa26596e91ba32e19b0c448523058059841cf8788ac801a0600000000001976a914b705b67a8c0caeb68bbafe8377da8c19aff1e2e788ac64952e00000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac000000000000000000')
    end
  end

  
end
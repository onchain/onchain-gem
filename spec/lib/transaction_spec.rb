require 'spec_helper'

describe OnChain do
  
  REDEMPTION_SCRIPTS = ["522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952ae",
    "522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352ae" ]
    
  HANDY_KEY = "xprv9vHD6wsW4Zxo354gwDBGWfAJk4LFY3M19Eq64Th11mwE4mjPXRC6hopudBbHzWDuJp9m3b4HtYwJR3QfBPMM6tYJvZeMFaMt5iDcP1sqoWw"
  
  it "should create a valid transaction" do
    
    tx, inputs_to_sign = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000)
      
    expect(tx).to eq("01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff01662c0000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000")
  
    expect(inputs_to_sign[0]['02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[0]['0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[1]['02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
    expect(inputs_to_sign[1]['034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
  end
  
  it "should create a partially signed transaction" do
    
    tx, inputs_to_sign = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000)
    
    sign_with_key(inputs_to_sign, HANDY_KEY)
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  it "should add sigs to a prefilled inputs JSON" do
    
    json =  "[{\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\"},\"0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\",\"sig\":\"304502200a2bff6a4da53e3376c36d943dc9d43addc18b667f5892411e55ccaea8b3b779022100f4f2a1c121e75cd80137b2c38fdf90f4da634ab6c159005d530eb9cfe3e93f60\"}},{\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\"},\"034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\",\"sig\":\"3044022079dda685df2d0294d076b52b42fc298d2dc7a1300b93bec3216470bdc2619af2022028f2c97aa412933d515e82596b45b57c33463be63812cb60acad981f9505a021\"}}]" 

    inputs_to_sign = JSON.parse(json)
    
    sign_with_key(inputs_to_sign, HANDY_KEY)
    
    tx = "01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff0156050000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000"
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  it "should know when everything is signed" do
    
    json =  "[{\"0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\",\"sig\":\"304502200a2bff6a4da53e3376c36d943dc9d43addc18b667f5892411e55ccaea8b3b779022100f4f2a1c121e75cd80137b2c38fdf90f4da634ab6c159005d530eb9cfe3e93f60\"},\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\",\"sig\":\"3044022068A4089837868A66CB0FB57B42402B7737A545C7C9C477AC0C32014B071AA6F00220496817E80491BF50B470E4873F7209DE381EC5CB0282B2FD72D179EB4D73B3E5\"}},{\"034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\",\"sig\":\"3044022079dda685df2d0294d076b52b42fc298d2dc7a1300b93bec3216470bdc2619af2022028f2c97aa412933d515e82596b45b57c33463be63812cb60acad981f9505a021\"},\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\",\"sig\":\"3044022070F80D04FE1513F9F303B2F8E327EFD1F3267C82109F6CCBC555393F80B617E6022004BC584B859810D0E7636320B4AFE86FB9C74E8BEFB478AFAFC10A0CD7CB8A95\"}}]"
    inputs_to_sign = JSON.parse(json)
    
    sign_with_key(inputs_to_sign, HANDY_KEY)
    
    tx = "01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff0156050000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000"
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
    
    expect(OnChain::Transaction.do_we_have_all_the_signatures(inputs_to_sign)).to eq(true)
  end
  
  it "should work with a fully filled in sig list" do
    
    tx = "010000000132448fc909b395d7f9e393d830c56b80bb0609d9977be173f1fdff03c51515390000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc42102388085f9b6bbfb1c353b2664cf1857ff6d11c3f93b0635a31204bcbbb9e0403d52aeffffffff02a0860100000000001976a914ef7aeda00f357959ad628405753b41cfb778bde188ac0a5700000000000017a9143b04977278415be296acc65f83084341871ef9f08700000000"
    
    meta =  "[{\"02388085f9b6bbfb1c353b2664cf1857ff6d11c3f93b0635a31204bcbbb9e0403d\":{\"hash\":\"fff5fad59856c594e5d226212712777a32f6c0cd5db384656ee08504a382c5db\",\"sig\":\"3046022100f6309c26186de8fbc020df9e7aee13b90ce1b9f195f7638c36e36b079189c17e022100bd14a491fb4916dee84d73ae1ed867dd3e3fa80f1e2e6dc507d3cfcb90348f1e\"},\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"fff5fad59856c594e5d226212712777a32f6c0cd5db384656ee08504a382c5db\",\"sig\":\"30440220584C636D197D49709689C323F094550CE14DC75B9C80110D30FC8ED7C7ED869B02200848DF218C83CB8A62BE0A19C4D5EF88D40F0233220596784632B7ED43E31240\"}}]" 
    
    inputs_to_sign = JSON.parse(meta)
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  def sign_with_eckey(inputs_to_sign, pk)
    
    pub_hex = pk.pub
    
    inputs_to_sign.each do |input|
      
      if input[pub_hex] != nil
        
        hash_to_sign = input[pub_hex]["hash"]
        
        sig =  OnChain.bin_to_hex(pk.sign(OnChain.hex_to_bin(hash_to_sign)))
        
        input[pub_hex]["sig"] = sig
      end
    end
  end
  
  def sign_with_key(inputs_to_sign, key)
    
    node = MoneyTree::Node.from_serialized_address key
    
    inputs_to_sign.each do |input|
      
      if input[node.public_key.to_hex] != nil
        
        wif = node.private_key.to_hex
        pk = Bitcoin::Key.new wif
        
        hash_to_sign = input[node.public_key.to_hex]["hash"]
        
        sig =  OnChain.bin_to_hex(pk.sign(OnChain.hex_to_bin(hash_to_sign)))
        
        input[node.public_key.to_hex]["sig"] = sig
      end
    end
  end
  
end
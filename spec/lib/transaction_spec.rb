require 'spec_helper'

describe OnChain do
  
  REDEMPTION_SCRIPTS = ["522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952ae",
    "522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352ae" ]
    
  HANDY_KEY = "xprv9vHD6wsW4Zxo354gwDBGWfAJk4LFY3M19Eq64Th11mwE4mjPXRC6hopudBbHzWDuJp9m3b4HtYwJR3QfBPMM6tYJvZeMFaMt5iDcP1sqoWw"
  
  
  it "get recommended transaction fee" do
    fee = OnChain::Transaction.get_recommended_tx_fee["fastestFee"]
    
    expect(fee).to be > 0
  end
  
  it "should estimate transaction sizes" do
    orig_addr = '13H8HWUgyaeMXJoDnKeUFMcXLJbCQ7s7V5'
    
    OnChain::Transaction.estimate_transaction_size([orig_addr], 0.38 * 100_000_000)
  end
  
  it "should calculate the miners fee" do
    
    orig_addr = '1HMTY59ZaVB9L4rh7PjMjEca2fiT1TucGH'
    
    fee = OnChain::Transaction.calculate_miners_fee([orig_addr], 1000000)
    
    expect(fee).to be > 1000
  end
  
  it "should sign a hash160 style transaction" do
    
    json_sig_list = '[{"1JCLW7cvVv2aHvcCUc4284unoaKXciftzW":{"hash":"cd165db44251e7aadb661bba68d5b1b1a50f0b2b7401275783d1b627c0a503a7","sig":"30440220078055cb1bc4afd13daf27b1999a91444b37858ad5ec91cfb05a5d56722169170220154f0459f50f989d917e4f4da1fcf06398c108b729337e711c83577b731405fd"}},{"1JCLW7cvVv2aHvcCUc4284unoaKXciftzW":{"hash":"f397dbe6d322a9b066594db64961dfe44b70710df4d9b5b1b4c433295965ebb9","sig":"3045022100a4061fb091da793651c7e267d6fe170e6429ead718203f71b3fb46e25e0b83c102202a7d80c56ae69d8ba6924da0b4c49e0d7a652b76041662dcc432bf50c3e5887e"}},{"1JCLW7cvVv2aHvcCUc4284unoaKXciftzW":{"hash":"9777c4cdd87916b28cebbec24a30be291af5944157c07467ede35712ccb17281","sig":"3045022100e7ab9522b816b2293bdb671809cbb3e05f36b58e9ff37daffd2046ab86da79f202207bec09653ab4d3f7602c027308ca371cbad44fe8f7f028495837e6aa65e9ea62"}}]'
    
    sig_list = JSON.parse(json_sig_list)
    
    txhex = "0100000003415af4aa41ea3c401d1cbd0262e4676c4b7b2b42bb7ba5ba528b84882858642b000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff415af4aa41ea3c401d1cbd0262e4676c4b7b2b42bb7ba5ba528b84882858642b020000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff064e15e63cf68122bc40582f692d557725fbbcb8f657712e0586772dd6b4331d000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff03a0860100000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac70f30500000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488aca0860100000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788ac00000000"
    
    pubkey = "0485527a4c5ae92e625c5793e742b351aa9b09f624a3d479184e6c33b0ac934f7ba8be8813765835a833a604e00b36362a827ef42523f3d1fc63ce02cb53be4446"
    
    tx_signed = OnChain::Transaction.sign_transaction(txhex, sig_list, pubkey)
    
    expect(tx_signed).to eq("0100000003415af4aa41ea3c401d1cbd0262e4676c4b7b2b42bb7ba5ba528b84882858642b000000008a4730440220078055cb1bc4afd13daf27b1999a91444b37858ad5ec91cfb05a5d56722169170220154f0459f50f989d917e4f4da1fcf06398c108b729337e711c83577b731405fd01410485527a4c5ae92e625c5793e742b351aa9b09f624a3d479184e6c33b0ac934f7ba8be8813765835a833a604e00b36362a827ef42523f3d1fc63ce02cb53be4446ffffffff415af4aa41ea3c401d1cbd0262e4676c4b7b2b42bb7ba5ba528b84882858642b020000008b483045022100a4061fb091da793651c7e267d6fe170e6429ead718203f71b3fb46e25e0b83c102202a7d80c56ae69d8ba6924da0b4c49e0d7a652b76041662dcc432bf50c3e5887e01410485527a4c5ae92e625c5793e742b351aa9b09f624a3d479184e6c33b0ac934f7ba8be8813765835a833a604e00b36362a827ef42523f3d1fc63ce02cb53be4446ffffffff064e15e63cf68122bc40582f692d557725fbbcb8f657712e0586772dd6b4331d000000008b483045022100e7ab9522b816b2293bdb671809cbb3e05f36b58e9ff37daffd2046ab86da79f202207bec09653ab4d3f7602c027308ca371cbad44fe8f7f028495837e6aa65e9ea6201410485527a4c5ae92e625c5793e742b351aa9b09f624a3d479184e6c33b0ac934f7ba8be8813765835a833a604e00b36362a827ef42523f3d1fc63ce02cb53be4446ffffffff03a0860100000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac70f30500000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488aca0860100000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788ac00000000")
  end
  
  it "should interrogate a transaction" do
    
    txhex = "01000000016b631e692ec8481265a73a7ce643722c72145049bb0696bb2e8ada67f7a751cb0000000047522103ae9006247d18249116381e0fd1f87df3ce5295995873a81394a9dfb4a96096dd210221b9cb16c1cb3f1d493cbe73f3dd79c8483fd54b7335f5057427a00aacb23ab552aeffffffff0300e1f5050000000017a9140c01e8d5ed4d6de3719e9a11af596bc242bfae698724a00e00000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac89ad2b020000000017a914ca97c2df84cb614feab88f0f6369b1017be80b818700000000"
    
    total_input_value = 137_416_905
    
    result = OnChain::Transaction.interrogate_transaction(txhex, 
      ['3LAEDr9PuQkU2hnKERaHATgJ1SrDdVzWd3'], 
      ['1JXYMviGfEvjYGP2ZGfDJku6EjnPPEgtr6'], total_input_value)
      
    expect(result[:miners_fee]).to eq(0.000415)
    expect(result[:total_change]).to eq(0.36416905)
    expect(result[:total_to_send]).to eq(1.37416905)
    expect(result[:our_fees]).to eq(0.009585)
    expect(result[:destination]).to eq("32nWKXBDkEV8vb2B4ZKR54mwzN897WpCnS")
    expect(result[:unrecognised_destination]).to eq(0.0)
    expect(result[:primary_send]).to eq(1.0)
    
  end
  
  it "should interrogate an affiliate transaction" do
    
    txhex = "010000000275fe229c43fa1a89412e793bb0048e8cd72cc377c462ae2c4e953811b950f794020000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff0afe22c61aa6ad6b066245ae4fca4f1e2f083e61b3d1c58d17ac3173e9ce7b4b000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff04a0860100000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac30e60200000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac30e60200000000001976a9147a2e64eec19154ed1792c3b9c07bae900e5e74df88aca0860100000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788ac00000000"
    
    total_input_value = 600_000
    
    result = OnChain::Transaction.interrogate_transaction(txhex, 
      ['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'], 
      ['1STRonGxnFTeJiA7pgyneKknR29AwBM77', 
      '1C931w9YKHeogc8N4zRUKSvitoPcTPKPFf'], total_input_value)
      
    expect(result[:miners_fee]).to eq(0.0002)
    expect(result[:total_change]).to eq(0.001)
    expect(result[:total_to_send]).to eq(0.006)
    expect(result[:our_fees]).to eq(0.0038)
    expect(result[:destination]).to eq("1JXYMviGfEvjYGP2ZGfDJku6EjnPPEgtr6")
    expect(result[:unrecognised_destination]).to eq(0.0)
    expect(result[:primary_send]).to eq(0.001)
    
  end
  
  it "should sanity check a transaction" do
    
    tx = '010000000168e118d870ce6c30a6fc2f857f1a55909a500551e7d441ff368e595ce062dd26020000008a47304402207d687b513ee58c6cb9348613735d20320b74e9c80845db44f8032ec75125a7a5022058bb5f1d705d0b5701583aac690c0ff1b537e5f24342093e8d559b30681c96920141047299bb198fbcd6992000e1557fd63278feb44b313b7a2c4f735ca99fb73e65de24aa9a17858686942e63b4db467f60d50ef77c362b1b50ac6ca2a7eacfe85f3cffffffff03808d5b00000000001976a9141969dd3c9f1765fd923c8c9c1ad52a26410ed12688ac801a0600000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac40771b00000000001976a914b3607b90aa91452f234d85ec2809d0037e71f38788ac00000000'
    
    orig_addr = '1HMTY59ZaVB9L4rh7PjMjEca2fiT1TucGH'
    dest_addr = ''
    
    amount = 0.82 * 100000000
    
    OnChain::Transaction.check_integrity(tx, amount, [orig_addr], dest_addr, 0.1)
    
    error = nil
    begin
      OnChain::Transaction.check_integrity(tx, 1, [orig_addr], dest_addr, 0.1)
    rescue => e
      error = e.message
    end
    expect(error).to eq("Transaction has more input value (6500000) than the tolerence 1.1")
    
    error = nil
    begin
      OnChain::Transaction.check_integrity(tx, amount, ['1HELLOZaVB9L4rh7PjMjEca2fiT1TucGH'], dest_addr, 0.1)
    rescue => e
      error = e.message
    end
    expect(error).to eq("One of the inputs is not from from our list of valid originating addresses")
    
  end
  
  it "should create a valid transaction" do
    
    tx, inputs_to_sign, total = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000, 0, nil)
      
    expect(tx).to eq("01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff01662c0000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000")

    expect(inputs_to_sign[0]['02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[0]['0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[1]['02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
    expect(inputs_to_sign[1]['034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
  end
  
  it "should create a partially signed transaction" do
    
    tx, inputs_to_sign = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000, 0, nil)
    
    sign_with_key(inputs_to_sign, HANDY_KEY)
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  it "should add sigs to a prefilled inputs JSON" do
    
    json =  "[{\"12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\"},\"0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\",\"sig\":\"304502200a2bff6a4da53e3376c36d943dc9d43addc18b667f5892411e55ccaea8b3b779022100f4f2a1c121e75cd80137b2c38fdf90f4da634ab6c159005d530eb9cfe3e93f60\"}},{\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\"},\"034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\",\"sig\":\"3044022079dda685df2d0294d076b52b42fc298d2dc7a1300b93bec3216470bdc2619af2022028f2c97aa412933d515e82596b45b57c33463be63812cb60acad981f9505a021\"}}]" 

    inputs_to_sign = JSON.parse(json)
    
    sign_with_key(inputs_to_sign, HANDY_KEY)
    
    tx = "01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff0156050000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000"
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  it "should know when everything is signed" do
    
    json =  "[{\"13Rshy6vqefuVggz3YQdh2yhBtWZegXyJV\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\",\"sig\":\"304502200a2bff6a4da53e3376c36d943dc9d43addc18b667f5892411e55ccaea8b3b779022100f4f2a1c121e75cd80137b2c38fdf90f4da634ab6c159005d530eb9cfe3e93f60\"},\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"fddf486c62c0c89eb9d8bd054e6bffb504fdf70239e315074676d9f65c49bd1b\",\"sig\":\"3044022068A4089837868A66CB0FB57B42402B7737A545C7C9C477AC0C32014B071AA6F00220496817E80491BF50B470E4873F7209DE381EC5CB0282B2FD72D179EB4D73B3E5\"}},{\"034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\",\"sig\":\"3044022079dda685df2d0294d076b52b42fc298d2dc7a1300b93bec3216470bdc2619af2022028f2c97aa412933d515e82596b45b57c33463be63812cb60acad981f9505a021\"},\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"2fb8960eecf2fe2a9268953cb564e27b669e570fc39c7b100f9706e6339ffdf5\",\"sig\":\"3044022070F80D04FE1513F9F303B2F8E327EFD1F3267C82109F6CCBC555393F80B617E6022004BC584B859810D0E7636320B4AFE86FB9C74E8BEFB478AFAFC10A0CD7CB8A95\"}}]"
    inputs_to_sign = JSON.parse(json)
    
    sign_with_key(inputs_to_sign, HANDY_KEY)
    
    tx = "01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff0156050000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000"
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
    
    expect(OnChain::Transaction.do_we_have_all_the_signatures(inputs_to_sign)).to eq(true)
  end
  
  it "should work with a fully filled in sig list" do
    
    tx = "010000000132448fc909b395d7f9e393d830c56b80bb0609d9977be173f1fdff03c51515390000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc42102388085f9b6bbfb1c353b2664cf1857ff6d11c3f93b0635a31204bcbbb9e0403d52aeffffffff02a0860100000000001976a914ef7aeda00f357959ad628405753b41cfb778bde188ac0a5700000000000017a9143b04977278415be296acc65f83084341871ef9f08700000000"
    
    meta =  "[{\"02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4\":{\"hash\":\"fff5fad59856c594e5d226212712777a32f6c0cd5db384656ee08504a382c5db\",\"sig\":\"3046022100f6309c26186de8fbc020df9e7aee13b90ce1b9f195f7638c36e36b079189c17e022100bd14a491fb4916dee84d73ae1ed867dd3e3fa80f1e2e6dc507d3cfcb90348f1e\"},\"12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM\":{\"hash\":\"fff5fad59856c594e5d226212712777a32f6c0cd5db384656ee08504a382c5db\",\"sig\":\"30440220584C636D197D49709689C323F094550CE14DC75B9C80110D30FC8ED7C7ED869B02200848DF218C83CB8A62BE0A19C4D5EF88D40F0233220596784632B7ED43E31240\"}}]" 
    
    inputs_to_sign = JSON.parse(meta)
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  it "should create a valid transaction with affiliate fee" do
    
    tx, inputs_to_sign = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366,  0, 0, 
      ['1STRonGxnFTeJiA7pgyneKknR29AwBM77', '15akUMqYsKMwJzYKdEK4WKYzMpCruNV3pr'])
      
    expect(tx).to eq("01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff01662c0000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000")

    expect(inputs_to_sign[0]['02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[0]['0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[1]['02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
    expect(inputs_to_sign[1]['034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
  end
  
  it "should generate the same hashes each time" do
  end
  
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
  
  def sign_with_key(inputs_to_sign, key)
    
    node = MoneyTree::Node.from_bip32 key
    
    inputs_to_sign.each do |input|
      
      pub_addr = node.public_key.to_hex
      
      if input[pub_addr] != nil
        
        wif = node.private_key.to_hex
        pk = Bitcoin::Key.new wif
        
        hash_to_sign = input[pub_addr]["hash"]
        
        sig =  OnChain.bin_to_hex(pk.sign(OnChain.hex_to_bin(hash_to_sign)))
        
        input[pub_addr]["sig"] = sig
      end
    end
  end
  
end
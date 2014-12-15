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

    expect(inputs_to_sign[0]['12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[0]['13Rshy6vqefuVggz3YQdh2yhBtWZegXyJV']['hash']).to eq('355ab58049169af3ab36486e0b8251279027f5c0e195422fcd25c36668d3c0e7')
    expect(inputs_to_sign[1]['12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
    expect(inputs_to_sign[1]['1HA9vP25L61dVBVA8CpK7fAyWj2kRHWeuQ']['hash']).to eq('f14b88c7d42f10e23f307fd14ee997870e8f8825d0fc2092be5aabd8eec81735')
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
    
    meta =  "[{\"1ymRJ9tHJvgeu8VDBCUMfgJdHnAFUrV38\":{\"hash\":\"fff5fad59856c594e5d226212712777a32f6c0cd5db384656ee08504a382c5db\",\"sig\":\"3046022100f6309c26186de8fbc020df9e7aee13b90ce1b9f195f7638c36e36b079189c17e022100bd14a491fb4916dee84d73ae1ed867dd3e3fa80f1e2e6dc507d3cfcb90348f1e\"},\"12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM\":{\"hash\":\"fff5fad59856c594e5d226212712777a32f6c0cd5db384656ee08504a382c5db\",\"sig\":\"30440220584C636D197D49709689C323F094550CE14DC75B9C80110D30FC8ED7C7ED869B02200848DF218C83CB8A62BE0A19C4D5EF88D40F0233220596784632B7ED43E31240\"}}]" 
    
    inputs_to_sign = JSON.parse(meta)
    
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign)
    
    expect(tx_signed.length).to be > tx.length
  end
  
  it "should verify the signatures" do
    
    sig_list = '[{"04f38a0124afe10f06cad3d4cbf9159f63443a63d4219d9316a411901348b4ccff517a812ba2578ef97bf8d0cd1a18d5f1de0a697529186c26e51ffb895a1c9e51":{"hash":"7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c","sig":"304402200cd8a52cae53fce9860bd47468ee137216aa2cf3f1d98f9abb520e3940598b4c02202f27a5ab0d5a75c3e4958cf72373b59865f71899798208d482d2329e0773ac6801"},"0498ef09c13a496507999e6b08cbebc059f4751c94929388108e421c93bf7520216eabdfca6216b579e48c7a830e09e7343a277e59236be72e920a5a9bd021d2ae":{"hash":"7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c","sig":"3046022100c20ecf3b129a04967a05e3508cf0b85af65b0bafe7e1264d56dddce2c2d68010022100b054e0482d28dfc80539b96729fde99cbaaad59653127ce860b6472671a37b0e01"},"0476c3b254aec505f7aefa5ba172d85f4df6a03bba905a89775dadee5a07e283f9035d13572f8a345b66052111b20c75a106750bcac946f3c24a3355ba9e65e944":{"hash":"7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c"}}]'

    key1 = Bitcoin::Key.from_base58('5KAovUBbq3uBUQBPPr6RABJVnh4fy6E49dbQjqhwE8HEoCDTA19')
    key2 = Bitcoin::Key.from_base58('5JefEur75YYjxHJjmJDaTRAL8hY8GWvLxTwHn11HZQWwcySKfrn')
    
    expect(verify_sigs(JSON.parse(sig_list), [key1, key2])).to eq(true)
    
    wrong_sig_list = '[{"04f38a0124afe10f06cad3d4cbf9159f63443a63d4219d9316a411901348b4ccff517a812ba2578ef97bf8d0cd1a18d5f1de0a697529186c26e51ffb895a1c9e51":{"hash":"7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c","sig":"304402200cd8a52cae53fce9860bd47468ee137216aa2cf3f1d98f9abb520e3940598b4c02202f27a5ab0d5a75c3e4958cf72373b59865f71899798208d482d2329e0773ac6901"},"0498ef09c13a496507999e6b08cbebc059f4751c94929388108e421c93bf7520216eabdfca6216b579e48c7a830e09e7343a277e59236be72e920a5a9bd021d2ae":{"hash":"7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c","sig":"3046022100c20ecf3b129a04967a05e3508cf0b85af65b0bafe7e1264d56dddce2c2d68010022100b054e0482d28dfc80539b96729fde99cbaaad59653127ce860b6472671a37b0e01"},"0476c3b254aec505f7aefa5ba172d85f4df6a03bba905a89775dadee5a07e283f9035d13572f8a345b66052111b20c75a106750bcac946f3c24a3355ba9e65e944":{"hash":"7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c"}}]'

    expect(verify_sigs(JSON.parse(wrong_sig_list), [key1, key2])).to eq(false)
    
    hash = "7cb61d8a1420d0d6dfb560c018b796d77ac5600e9a02d378fa023f94b8b5d34c"
    sig = "304402200cd8a52cae53fce9860bd47468ee137216aa2cf3f1d98f9abb520e3940598b4c02202f27a5ab0d5a75c3e4958cf72373b59865f71899798208d482d2329e0773ac6801"
    
    expect(key1.verify(OnChain.hex_to_bin(hash), OnChain.hex_to_bin(sig))).to eq(true)
    
    sig_without_push = "304402200cd8a52cae53fce9860bd47468ee137216aa2cf3f1d98f9abb520e3940598b4c02202f27a5ab0d5a75c3e4958cf72373b59865f71899798208d482d2329e0773ac68"
    
    expect(key1.verify(OnChain.hex_to_bin(hash), OnChain.hex_to_bin(sig_without_push))).to eq(true)
    
    chnage_sig = "304402200cd8a52cae53fce9860bd48468ee137216aa2cf3f1d98f9abb520e3940598b4c02202f27a5ab0d5a75c3e4958cf72373b59865f71899798208d482d2329e0773ac68"
    
    expect(key1.verify(OnChain.hex_to_bin(hash), OnChain.hex_to_bin(chnage_sig))).to eq(false)
  end
  
  # The addresses here were generate by
  # https://coinb.in/multisig/
  it "should work with some keys we generated online" do
    
    key1 = Bitcoin::Key.from_base58('5KAovUBbq3uBUQBPPr6RABJVnh4fy6E49dbQjqhwE8HEoCDTA19')
    key2 = Bitcoin::Key.from_base58('5JefEur75YYjxHJjmJDaTRAL8hY8GWvLxTwHn11HZQWwcySKfrn')
    # key3, even though we only need 2 to sign.
    key3 = Bitcoin::Key.from_base58('5JqeHF3fUmdNXukL5yXpdkZs4d4PwXrW6C1qB2CMcd6Axn19BJ6')
    
    # If you want the pub keys in hex, jsut do key1.pub etc..

    expect(key1.addr).to eq('1MWr2FY4XLfEzZ7PQPELNwFkog83vwh6a1')
    expect(key2.addr).to eq('1CZn88sLyLNe6zwJsPLYkj9DTsHXVWi3TU')
    expect(key3.addr).to eq('1CGTzS1etxKMRP16eys6nyYsh7xDjnMyw6')
    
    rs = OnChain::Sweeper.generate_redemption_script(2, [key1.pub, key2.pub, key3.pub])
    
    addr = OnChain::Sweeper.generate_address_of_redemption_script(rs)
    expect(addr).to eq('32x4ufepcDX9MtgxWMbi6RQgJuxGW5fjc7')
    
    addr = "13qu9Dn64kX4W7KrAs9ZwwxvW5HRu4KNL2"
    
    tx, sig_list = OnChain::Transaction.create_transaction([rs], addr, 10000, 10000)
    
    sign_with_eckey(sig_list, key1)
    sign_with_eckey(sig_list, key2)
    
    signed_tx = OnChain::Transaction.sign_transaction(tx, sig_list)
    
    # The signed TX created here does broadcast.
    
    expect(signed_tx.length).to be > tx.length
    
  end
  
  it "should work with 2 of 2 address" do
    
    key1 = Bitcoin::Key.from_base58('5KAovUBbq3uBUQBPPr6RABJVnh4fy6E49dbQjqhwE8HEoCDTA19')
    key2 = Bitcoin::Key.from_base58('5JefEur75YYjxHJjmJDaTRAL8hY8GWvLxTwHn11HZQWwcySKfrn')
    
    # If you want the pub keys in hex, jsut do key1.pub etc..

    expect(key1.addr).to eq('1MWr2FY4XLfEzZ7PQPELNwFkog83vwh6a1')
    expect(key2.addr).to eq('1CZn88sLyLNe6zwJsPLYkj9DTsHXVWi3TU')
    
    rs = OnChain::Sweeper.generate_redemption_script(2, [key1.pub, key2.pub])
    
    addr = OnChain::Sweeper.generate_address_of_redemption_script(rs)
    expect(addr).to eq('3JkJ2LdCssWJBDbq5tpRdN8D5wwgdHt6KY')
    
    addr = "13qu9Dn64kX4W7KrAs9ZwwxvW5HRu4KNL2"
    
    tx, sig_list = OnChain::Transaction.create_transaction([rs], addr, 10000, 10000)
    
    sign_with_eckey(sig_list, key1)
    sign_with_eckey(sig_list, key2)
    
    signed_tx = OnChain::Transaction.sign_transaction(tx, sig_list)
    
    # The signed 2 of 2 TX created here does broadcast.
    
    expect(signed_tx.length).to be > tx.length
  end
  
  it "should work with 2 of 2 address from handy key" do

    # Using the handy key.
    node = MoneyTree::Master.from_serialized_address HANDY_KEY
    wif = node.private_key.to_hex
    key1 = Bitcoin::Key.new wif
    
    key2 = Bitcoin::Key.from_base58('5JefEur75YYjxHJjmJDaTRAL8hY8GWvLxTwHn11HZQWwcySKfrn')
    
    # If you want the pub keys in hex, jsut do key1.pub etc..

    expect(key1.addr).to eq('12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM')
    expect(key2.addr).to eq('1CZn88sLyLNe6zwJsPLYkj9DTsHXVWi3TU')
    
    rs = OnChain::Sweeper.generate_redemption_script(2, [key1.pub, key2.pub])
    
    addr = OnChain::Sweeper.generate_address_of_redemption_script(rs)
    expect(addr).to eq('3BWVzVCo9DejAeFsZvkV6AysnTLHzyMYWk')
    
    addr = "13qu9Dn64kX4W7KrAs9ZwwxvW5HRu4KNL2"
    
    tx, sig_list = OnChain::Transaction.create_transaction([rs], addr, 10000, 10000)
    
    sign_with_eckey(sig_list, key1)
    sign_with_eckey(sig_list, key2)
    
    signed_tx = OnChain::Transaction.sign_transaction(tx, sig_list)
    
    # The signed 2 of 2 TX created here does broadcast.
    
    expect(signed_tx.length).to be > tx.length
  end
  
  it "should work with 2 of 2 address from onchain js" do

    # Generated from onchain
    key1 = Bitcoin::Key.from_base58('L1qmBUV5BpdQ1dU6kziEBWsvvrsp3JUmgSNRg6u85sULH2GcFvSQ')
    
    key2 = Bitcoin::Key.from_base58('5JefEur75YYjxHJjmJDaTRAL8hY8GWvLxTwHn11HZQWwcySKfrn')
    
    # If you want the pub keys in hex, jsut do key1.pub etc..

    expect(key1.addr).to eq('1ymRJ9tHJvgeu8VDBCUMfgJdHnAFUrV38')
    expect(key2.addr).to eq('1CZn88sLyLNe6zwJsPLYkj9DTsHXVWi3TU')
    
    rs = OnChain::Sweeper.generate_redemption_script(2, [key1.pub, key2.pub])
    
    addr = OnChain::Sweeper.generate_address_of_redemption_script(rs)
    expect(addr).to eq('3N7KLdtWDJkfzPWPgs6JY8zXgTuY6tpw3o')
    
    addr = "13qu9Dn64kX4W7KrAs9ZwwxvW5HRu4KNL2"
    
    tx, sig_list = OnChain::Transaction.create_transaction([rs], addr, 10000, 10000)
    
    sign_with_eckey(sig_list, key1)
    sign_with_eckey(sig_list, key2)
    
    signed_tx = OnChain::Transaction.sign_transaction(tx, sig_list)
    
    # The signed 2 of 2 TX created here does broadcast.
    
    expect(signed_tx.length).to be > tx.length
  end
  
  it "should sign with onchian and handy keys" do
    
    # We have the HANDY PK and the onchain pk used in JS.
    # Can we do this in ruby ?

    node = MoneyTree::Master.from_serialized_address HANDY_KEY
    wif = node.private_key.to_hex
    key1 = Bitcoin::Key.new wif
    
    key2 = Bitcoin::Key.from_base58 'L1qmBUV5BpdQ1dU6kziEBWsvvrsp3JUmgSNRg6u85sULH2GcFvSQ'

    expect(key1.addr).to eq('12DRYpGnHbwgogprfwbM1NKd9Brr79KGyM')
    expect(key2.addr).to eq('1ymRJ9tHJvgeu8VDBCUMfgJdHnAFUrV38')
    
    rs = OnChain::Sweeper.generate_redemption_script(2, [key1.pub, key2.pub])
    
    addr = OnChain::Sweeper.generate_address_of_redemption_script(rs)
    expect(addr).to eq('3755Htdj1i61xiToskjurApvVZGLMRXzSp')
    
    expect(rs).to eq("522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc42102388085f9b6bbfb1c353b2664cf1857ff6d11c3f93b0635a31204bcbbb9e0403d52ae")
    
    tx, sig_list = OnChain::Transaction.create_transaction(
      [rs], 
      '1NqFm3uosZ3qT26AvCFrKRhpNZfEpTSrX4', 10000, 10000)
    
    sign_with_eckey(sig_list, key1)
    sign_with_eckey(sig_list, key2)
    
    expect(verify_sigs(sig_list, [key1, key2])).to eq(true)
    
    signed_tx = OnChain::Transaction.sign_transaction(tx, sig_list)
    
    expect(signed_tx.length).to be > tx.length
    
    
    # Why doesn't this broadcast?
    #puts signed_tx
  end
  
  it "should generate the correct fee" do
    
    fee = OnChain::Transaction.calculate_fee(100000000, 1)
    expect(fee).to eq(1000000)
    
    fee = OnChain::Transaction.calculate_fee(1000000, 1)
    expect(fee).to eq(10000)
    
    # When it gets below the miners fee, stop adding.
    fee = OnChain::Transaction.calculate_fee(10000, 1)
    expect(fee).to eq(0)
  end

  
  it "should generate a create single address transaction" do
    
    tx, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 
      '13wKWNT8WcH12dXCuQQiH7KeDnsDgJs4Qd', 
      10000, 1, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77')
      
    expect(inputs_to_sign.count).to be > 0
    
  end
  
  it "should sign a single address transaction" do
    
    json = "[{\"1STRonGxnFTeJiA7pgyneKknR29AwBM77\":{\"hash\":\"fbd48b6d1940da8ccb8286561830b9cbcb4c129016793d5fb3303b58b333d0c5\",\"sig\":\"3046022100d50a69539df486b47921239180e1089cf9c95bda5ce9b30d72eb0100e0020641022100c855737ae37401e3cba6529a118bf792988b405e2e68fedc71acd644ec935c0f\"}}]" 
    inputs_to_sign = JSON.parse(json)
    
    tx = "01000000013a0415682f816627c0b95c7f71347c7be291f8c08ee1c783a99961f003455ef8010000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488acffffffff02a0860100000000001976a9142036296ef496e5550369f46d2b3258e21ad342de88ace0930400000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000"
    tx_signed = OnChain::Transaction.sign_transaction(tx, inputs_to_sign, "0428a450cfd9cc029658a7588d6bd515201d6231275b5431b0a6fc420606b0fecd34d3b804335c64f8fcb481eadccc8cb85078f2a0d27f0c86748f3d832c894a2d")
    
    expect(tx_signed.length).to be > tx.length
    
  end
  
  def verify_sigs(signed_inputs, keys)
    
    signed_inputs.each do |input|
      
      keys.each do |key|
        
        pub_hex = key.pub
      
        if input[pub_hex] != nil
        
          hash_to_sign = input[pub_hex]["hash"]
          sig = input[pub_hex]["sig"]

          if sig != nil
            
            res = key.verify(OnChain.hex_to_bin(hash_to_sign), OnChain.hex_to_bin(sig))
            
            if res == false
              return false
            end
          end
        end
      end
    end
    return true
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
    
    node = MoneyTree::Node.from_serialized_address key
    
    inputs_to_sign.each do |input|
      
      pub_addr = Bitcoin.hash160_to_address(Bitcoin.hash160(node.public_key.to_hex))
      
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
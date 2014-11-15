require 'spec_helper'

describe OnChain do
  
  REDEMPTION_SCRIPTS = ["522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952ae",
    "522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352ae" ]
  
  it "should create a valid transaction" do
    
    tx, hashes = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000)
      
    expect(tx).to eq("01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff01662c0000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000")
  
    expect(hashes[0]).to eq('02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4:07c5574ae48786421ad1f3e2d58eaf485c87ba83f134274465f503c0ec689c8a')
    expect(hashes[1]).to eq('0396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf99:07c5574ae48786421ad1f3e2d58eaf485c87ba83f134274465f503c0ec689c8a')
    expect(hashes[2]).to eq('02fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4:2fbab2b0240688630e50f38f7e3bed02382a7d38323a37f75230e27c0cbc6732')
    expect(hashes[3]).to eq('034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a83:2fbab2b0240688630e50f38f7e3bed02382a7d38323a37f75230e27c0cbc6732')
  end
  
  it "should create a partially signed transaction" do
    
    tx, hashes = OnChain::Transaction.create_transaction(
      REDEMPTION_SCRIPTS, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000)
      
      HANDY_KEY = "xprv9vHD6wsW4Zxo354gwDBGWfAJk4LFY3M19Eq64Th11mwE4mjPXRC6hopudBbHzWDuJp9m3b4HtYwJR3QfBPMM6tYJvZeMFaMt5iDcP1sqoWw"
      
      node = MoneyTree::Node.from_serialized_address HANDY_KEY
      
      signed_hashes = []
      
      hashes.each do |hash|
        
        if hash.split(':')[0] == node.public_key.to_hex
          
          wif = node.private_key.to_hex
          pk = Bitcoin::Key.new wif
          
          hash_to_sign = hash.split(':')[1]
          
          sig =  OnChain.bin_to_hex(pk.sign(OnChain.hex_to_bin(hash_to_sign)))
          
          signed_hashes << hash + ":" + sig
        else
          signed_hashes << hash
        end
        
      end
      
      OnChain::Transaction.sign_transaction(tx, signed_hashes)

      puts signed_hashes
    end
end
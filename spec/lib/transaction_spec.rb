require 'spec_helper'

describe OnChain do
  
  it "should create a valid transaction" do
    
    redemption_scripts = ["522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952ae",
      "522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352ae" ]
      
    tx, hashes = OnChain::Transaction.create_transaction(
      redemption_scripts, 
      '1STRonGxnFTeJiA7pgyneKknR29AwBM77', 11366, 10000)
      
    expect(tx).to eq("01000000029fd77c01b4f81f142e7e066eb9abeb4952ec5fdea51036acbb22b5ffeb57fd5f0100000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc4210396e42d3c584da0300ee44dcbaee0eccaa0e6ae2264fdd2554af6d2953f95bf9952aeffffffffc0161c6d62ac75f36bf95fcb2a8222f2274e86c2dcaec3434a0b6b6e0a6b60800000000047522102fd89e243d38f4e24237eaac4cd3a6873ce45aa4036ec0c7b79a4d4ac0fefebc421034000cea8f9cbaf88095d3ef539ee438e3cefea9ed9585e2e182b45496f071a8352aeffffffff01662c0000000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac00000000")
  end
  
end
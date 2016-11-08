require 'spec_helper'

describe OnChain do
  
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
  
  it "should give me a balance for a zcash address" do
    
    # We need ENV variables setup or the tests don't work
    expect(ENV['ZCASH_HOST']).to be_truthy   
    
    unspent =  OnChain::BlockChain.get_unspent_outs('t1JGmphaYLiAJ4CUx7qZirWNsMhsCk74idX', :zcash)
    
    expect(unspent).to be_a(Array)
    
    rawtx = OnChain::BlockChain.get_transaction('f9e2cb9cba139af2019adad7639a8b18e8895b6427956542afb7fb4ac0d451f6', :zcash)
    
    expect(rawtx).to eq('01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff1002b30e0c8ee30c00000000002f4e614effffffff02593b380b000000001976a9140461c2fa917ecaa5d2e54bba0d473b3b151b86e788ac3cbccd020000000017a9147d46a730d31f97b1930d3368a967c309bd4d136a8700000000')
     
    
    balance =  OnChain::BlockChain.get_balance('t1JGmphaYLiAJ4CUx7qZirWNsMhsCk74idX', :zcash)
    
    expect(balance).to eq(0)
  
  end
  
  it "should give me a history for a zcash address" do
    
    hist = OnChain::BlockChain.address_history('t1JGmphaYLiAJ4CUx7qZirWNsMhsCk74idX', :zcash)
    
    expect(hist.length).to be > 1
  end
  
  it "should send a transaction" do
    
    hist = OnChain::BlockChain.send_tx('01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff1002b30e0c8ee30c00000000002f4e614effffffff02593b380b000000001976a9140461c2fa917ecaa5d2e54bba0d473b3b151b86e788ac3cbccd020000000017a9147d46a730d31f97b1930d3368a967c309bd4d136a8700000000', :zcash)
    
    puts hist
  end
  
end
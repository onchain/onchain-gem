require 'spec_helper'

describe OnChain do
  
  it "should have the same TX as using onchain as the existing CW code" do
    
    redemption_scripts = ["5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102076355b7f2267a2c5f5cfeafa64e7906eda719ced2a4d1bc86c11ab5831e291952ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721034a36e40d323527594f0d763a068468e6570687701623a320b6c5387daa7278e352ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721039dd250fb2b079c71a687cb0cc7d417e204d1312cd950edc40ff05578572b45ea52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf7210210ae2fc4b148d194d969020a486065521bb1d5044da7a689aa7ae1a4dbab967152ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103efe27f3df867f0fde9267ff6dad14a9d4b25abefdd0a7a9088184cd9b98db8a052ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102dd99464ac3bc3820c05d5613c75bb1fa413c2a78c15b030c9c34414865f4761852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102d3be8d2c8377840296f8ed848eb841b8fff5786544572732b0a9bef19f96b0cd52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103624a33b708a68abc141f27342d29e51ccf5af73badc1c59df339a10173c7132d52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102f39be91aa0201e50c8a81a498ae57ba382c382c08a5f4f87f9dc6d770b00aede52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102d4b6e406951f224577ce4f6e62bf7665dc8f88213526ec187bbc9d8834b099a252ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103f5ad669eb358e5c206622e5617f3e18556c3754c75bf36c3f351eacf6873d08d52ae"]
    
    address = 't1cTbJE8Z6wrbVwegjUDvGKM3GtnVQyGS2t'
    amount = (0.01 * 100000000).to_i
    fee_percent = 0
    fee_addr = nil
    
    tx, inputs_to_sign = OnChain::Transaction.create_transaction(redemption_scripts, 
      address, amount, 0, fee_percent, fee_addr, :zclassic)
      
    expect(inputs_to_sign.count).to be > 0
    
    expect(tx).to eq("01000000014cfaefea18e52d0d66183529c5a7d1bd00f25f54508403fda26be4c62201b22101000000475221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102076355b7f2267a2c5f5cfeafa64e7906eda719ced2a4d1bc86c11ab5831e291952aeffffffff0240420f00000000001976a914cbdfd0ae6c5f64e9c2db4245d1eecbc37dd07df288ac00a60e000000000017a9147b6a53ff1a55244897532dd9d16cdf422cf6408d8700000000")
    
  end
  
  it "should give me a history for a zcash address" do
    
    hist = OnChain::BlockChain.address_history('t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx', :zclassic)
    
    expect(hist.length).to be > 0
  end
  
  it "should give me a balance for a zclassic address" do
    
    bal = OnChain::BlockChain.get_balance('t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx', :zclassic)
    
    expect(bal).to eq(0.0197337)
  end
  
  it "should get all balances" do
    
    addresses = ["t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx", "t3ao8bhnSLC1Ui5zALGVKLvmw9t9aF5m7Yt", "t3Nuf5VaGzLtohm5QMKKvWBbKoeWZAyKF2U", "t3es1giLrm5w5kcp9MuJorbEtJbPRvAmMaS", "t3UNYuPRBjrajjUf6Ss5empzdZWQTtFcy17", "t3ZbgWdEcwmmnzGnb2WyHFnidatgaxeLiBj", "t3K1K4ogzYsyG6eLLtyoosp84Y9dqByZsKM", "t3e2oWjoASHvL6edJHVDrVJGgw62CNY2XJy", "t3QJ12wGyAVnJsroNZ8JZq5sErrrYP5YBYv", "t3c1hnwTNx8uuGyJu9wdf61LT5tDP2EawZC", "t3SmmN8QnMA8BecAS4gn95yNGDsszoxLmQZ"]
    
    OnChain::BlockChain.get_all_balances(addresses, :zclassic)
  end
  
  it "should get the history" do
    
    addresses = ["t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx", "t3ao8bhnSLC1Ui5zALGVKLvmw9t9aF5m7Yt", "t3Nuf5VaGzLtohm5QMKKvWBbKoeWZAyKF2U", "t3es1giLrm5w5kcp9MuJorbEtJbPRvAmMaS", "t3UNYuPRBjrajjUf6Ss5empzdZWQTtFcy17", "t3ZbgWdEcwmmnzGnb2WyHFnidatgaxeLiBj", "t3K1K4ogzYsyG6eLLtyoosp84Y9dqByZsKM", "t3e2oWjoASHvL6edJHVDrVJGgw62CNY2XJy", "t3QJ12wGyAVnJsroNZ8JZq5sErrrYP5YBYv", "t3c1hnwTNx8uuGyJu9wdf61LT5tDP2EawZC", "t3SmmN8QnMA8BecAS4gn95yNGDsszoxLmQZ"]
    
    history = OnChain::BlockChain.get_history_for_addresses(addresses, :zclassic)
    
    expect(history.length).to be > 0
  end
  
  it "should get the balance in satoshi" do
    
    bal_satoshi = OnChain::BlockChain.get_balance_satoshi("t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx", :zclassic)
    
    expect(bal_satoshi).to be > 0
  end

end
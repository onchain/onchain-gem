require 'spec_helper'

describe OnChain do
  
  it "should give me a history for a zcash address" do
    
    hist = OnChain::BlockChain.address_history('t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx', :zclassic)
    
    expect(hist.length).to be > 0
  end
  
  it "should give me a balance for a zclassic address" do
    
    bal = OnChain::BlockChain.get_balance('t3VpBRHDLrQL8oDJuTaYNPJPcmFuW1L7yxx', :zclassic)
    
    expect(bal).to eq(0.9999)
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
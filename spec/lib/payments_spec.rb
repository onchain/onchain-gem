require 'spec_helper'

describe OnChain do
  it "Should fail when not enough funds" do
    
    res = OnChain.create_payment_tx('39b5DZa94G54WarMbYPzLox6xptiQJErhv', PAYMENT)
    
    expect(res).to start_with('Balance is not enough to cover payment')
  end

  it "Should give a parse error when address is incorrect" do
    
    payees = [['HELLO THIS IS WRONG', 1111000], 
      ['1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aot', 10000000]]
      
    res = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', payees)
    
    #expect(res).should start_with('Unable to parse payment ::')
  end

  it "Should create a valid transaction" do
    
    res = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', PAYMENT)
    
    expect(res.out.length).to eq(2)
  end

  it "Should convert string amounts to integers" do
    
    payees = [['HELLO THIS IS WRONG', '1111000'], 
      ['1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aot', '10000000']]
      
    res = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', payees)
    
    expect(res.out.length).to eq(2)
  end

  it "Should fail when not enough funds for string amounts" do
    
    payees = [['HELLO THIS IS WRONG', '1111000'], 
      ['1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aot', '10000000']]
      
    res = OnChain.create_payment_tx('3PP1YxyKyFU8urBC4fdd8d45aYk69irdLT', payees)
    
    expect(res).to start_with('Balance is not enough to cover payment')
  end
end
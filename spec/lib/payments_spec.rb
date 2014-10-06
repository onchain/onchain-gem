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
    
    expect(res).to start_with('Unable to parse payment ::')
  end

  it "Should create a valid transaction" do
    
    res = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', PAYMENT)
    
    expect(res.out.length).to eq(2)
  end

  it "Should convert string amounts to integers" do
    
    payees = [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', '1111000'], 
      ['1Nj3AsYfhHC4zVv1HHH4FzsYWeZSeVC8vj', '10000000']]
      
    res = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', payees)
    
    expect(res.out.length).to eq(2)
  end

  it "Should fail when not enough funds for string amounts" do
    
    payees = [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', '1111000'], 
      ['1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aot', '10000000']]
      
    res = OnChain.create_payment_tx('3PP1YxyKyFU8urBC4fdd8d45aYk69irdLT', payees)
    
    expect(res).to start_with('Balance is not enough to cover payment')
  end

  it "Should convert back and to from hex" do
    
    tx1 = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', PAYMENT)
    
    tx_hex = tx1.to_payload.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    tx_bin = tx_hex.scan(/../).map { |x| x.hex }.pack('c*')
    
    tx2 = Bitcoin::Protocol::Tx.new(tx_bin)
    
    expect(tx2.out.length).to eq(2)
  end

  it "Should be able to retreive address" do
    
    tx1 = OnChain.create_payment_tx('1BPqtqBKoUjEq8STWmJxhPqtsf3BKp5UyE', PAYMENT)
    
    expect(tx1.out[0].parsed_script.is_hash160?).to eq(true)
    
    expect(Bitcoin.hash160_to_address('04d075b3f501deeef5565143282b6cfe8fad5e94')).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77') 
    
    expect(tx1.out[0].parsed_script.get_hash160).to eq('04d075b3f501deeef5565143282b6cfe8fad5e94')
    
    expect(tx1.out[0].parsed_script.get_address).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
    
    tx_hex = tx1.to_payload.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    tx_bin = tx_hex.scan(/../).map { |x| x.hex }.pack('c*')
    
    tx2 = Bitcoin::Protocol::Tx.new(tx_bin)
    
    expect(tx2.out.length).to eq(2)
    
    expect(tx2.out[0].parsed_script.get_address).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
  end
end
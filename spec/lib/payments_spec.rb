require 'spec_helper'

describe OnChain do
  it "Should fail when not enough funds" do
    
    res = OnChain.create_payment_tx(REDEMPTION_SCRIPT_NO_BALANCE, PAYMENT)
    
    expect(res).to start_with('Balance is not enough to cover payment')
  end

  it "Should give a parse error when address is incorrect" do
    
    payees = [['HELLO THIS IS WRONG', 1000], 
      ['1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aot', 1000]]
      
    res = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, payees)
    
    expect(res).to start_with('Unable to parse payment ::')
  end

  it "Should create a valid transaction" do
    
    res = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, PAYMENT)
    
    expect(res.out.length).to eq(3)
  end

  it "Should convert string amounts to integers" do
    
    payees = [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', '1000'], 
      ['1Nj3AsYfhHC4zVv1HHH4FzsYWeZSeVC8vj', '10000']]
      
    res = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, payees)
    
    expect(res.out.length).to eq(3)
  end

  it "Should fail when not enough funds for string amounts" do
    
    payees = [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', '1111000'], 
      ['1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aot', '10000000']]
      
    res = OnChain.create_payment_tx(REDEMPTION_SCRIPT_NO_BALANCE, payees)
    
    expect(res).to start_with('Balance is not enough to cover payment')
  end

  it "Should convert back and to from hex" do
    
    tx1 = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, PAYMENT)
    
    tx_hex = tx1.to_payload.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    tx_bin = tx_hex.scan(/../).map { |x| x.hex }.pack('c*')
    
    tx2 = Bitcoin::Protocol::Tx.new(tx_bin)
    
    expect(tx2.out.length).to eq(3)
  end

  it "Should be able to retreive address" do
    
    tx1 = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, PAYMENT)
    
    expect(tx1.out[0].parsed_script.is_hash160?).to eq(true)
    
    expect(Bitcoin.hash160_to_address('04d075b3f501deeef5565143282b6cfe8fad5e94')).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77') 
    
    expect(tx1.out[0].parsed_script.get_hash160).to eq('04d075b3f501deeef5565143282b6cfe8fad5e94')
    
    expect(tx1.out[0].parsed_script.get_address).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
    
    tx_hex = tx1.to_payload.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    tx_bin = tx_hex.scan(/../).map { |x| x.hex }.pack('c*')
    
    tx2 = Bitcoin::Protocol::Tx.new(tx_bin)
    
    expect(tx2.out.length).to eq(3)
    
    expect(tx2.out[0].parsed_script.get_address).to eq('1STRonGxnFTeJiA7pgyneKknR29AwBM77')
  end

  it "Should have some inputs" do
    
    tx1 = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', 1000]])
    
    expect(tx1.in.length).to be > 0
    
    tx_hex = tx1.to_payload.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    tx_bin = tx_hex.scan(/../).map { |x| x.hex }.pack('c*')
    
    tx2 = Bitcoin::Protocol::Tx.new(tx_bin)
    
    expect(tx2.in.length).to be > 0
  end
  
  it "should give the correct address" do
    addr = OnChain.get_address_from_redemption_script(REDEMPTION_SCRIPT_WITH_BALANCE)
    
    expect(addr).to eq("39b5DZa94G54WarMbYPzLox6xptiQJErhv")
  end
  
  it "should create a multi sig script" do
    script = OnChain.hex_to_script(REDEMPTION_SCRIPT_NO_BALANCE)
    
    expect(script.is_multisig?).to eq(true)
  end
  
  it "should have a miners fee" do
    tx = OnChain.create_payment_tx(REDEMPTION_SCRIPT_WITH_BALANCE, [['1STRonGxnFTeJiA7pgyneKknR29AwBM77', 1000]])
    
    expect(tx.out.length).to be > 1
  end
  
  it "should have an input hash that corresponds to the unspent outs" do
    
    rs = '5121033cd4640df2a12dee1e74a649b05b698df30ea731cfd8056b33bcc66e419c91fc51ae'
    tx = OnChain.create_payment_tx(rs, [['34UjVHJ73AsRcDCDV9vuVKiQ9mwy3d2ix2', 10000]])
    
    expect(tx.in.length).to be == 1
    
    fund_address = OnChain.get_address_from_redemption_script(rs)
    unspent = OnChain.get_unspent_outs(fund_address)

    
    tx_hex = tx.to_payload.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    tx_bin = tx_hex.scan(/../).map { |x| x.hex }.pack('c*')
    
    tx2 = Bitcoin::Protocol::Tx.new(tx_bin)
    
    
    expect(tx2.in.length).to be == 1
    
    prev = tx2.in[0].prev_out.each_byte.map { |b| b.to_s(16).rjust(2, "0") }.join
    
    expect(prev).to be == unspent[0][0]
  end
end
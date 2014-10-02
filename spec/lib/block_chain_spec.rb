require 'spec_helper'

describe OnChain do
  
  it "Should retrieve a balance" do
    
    bal = OnChain.get_balance('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(bal).to eq(0.02)
    
  end
  
  it "Should give me unspent outs" do
    
    out = OnChain.get_unspent_outs('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(out.size).to eq(2)
    
    expect(out[0][0]).not_to  eq(nil)

  end
  
  it "Should get me a list of transactions" do
    
    txs = OnChain.get_transactions('1EscrowubAdwjYvRtpYLR2p6JRndNmjef3')
    
    expect(txs.size).to eq(2)
    
    expect(txs[0][0]).to eq('2009d4382d593d08842ad40bdf515446c4cd57c3e79489fb286a4c95c580e2a5')
    expect(txs[0][1]).to eq(1000000)
    
  end
end

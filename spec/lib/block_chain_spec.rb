require 'spec_helper'

describe OnChain do
  it "should be a zero balance" do
    OnChain.get_balance('1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aoc') == 0
  end
  
  it "Should give me unspent outs" do
    out = OnChain.get_unspent_outs('1NGJ2d2EgXTkdJQmaPek798DaALncfy8Ms')
    
    out.size == 1
    
    out[0][0] != nil

  end
end

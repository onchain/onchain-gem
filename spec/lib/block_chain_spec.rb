require 'spec_helper'

describe OnChain do
  it "should be a zero balance" do
    OnChain.get_balance('1MwVNWkpYRD9kuWMdUTBPdW8hVoQtG3Aoc') == 0
  end
end

require 'spec_helper'

describe OnChain do
  it "should say hello" do
    OnChain::Sweeper.sweep(['m/4', 'm/0'], MPK, '')
  end
end
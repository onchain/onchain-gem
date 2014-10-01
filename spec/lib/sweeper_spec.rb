require 'spec_helper'

describe OnChain do
  it "should say hello" do
    OnChain.sweep(['m/4', 'm/0'], MPK, '')
    
    key = Bitcoin::generate_key
    puts key
  end
end
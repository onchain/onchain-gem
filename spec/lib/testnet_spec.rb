require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
   "testnet_spec/" +  example.description
  end
  
  it "should give me a balance for a testnet address" do
    
    VCR.use_cassette(the_subject) do
      bal1 = OnChain::BlockChain.get_balance('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
      OnChain::BlockChain.cache_write('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', nil)
      
      expect(bal1).to eq(0.216)
    end
    
  end
  
  it "should give me the testnet unspent outs" do
    
    VCR.use_cassette(the_subject) do
      out1 = OnChain::BlockChain.get_unspent_outs('myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', :testnet3)
      
      expect(out1.count).to eq(4)
    end
  end
  
  it "should create a single address transaction on testnet" do
    
    
    VCR.use_cassette(the_subject) do
      tx, inputs_to_sign = OnChain::Transaction.create_single_address_transaction(
        'myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', 
        'mx97L7gTbERp8B7EK7Bk8R7bgnq6zUKAgY', 4000000, 
        30000, 'mkk7dRJz4288ux6kLmFi1w6GcHjJowtFc8', 10000, :testnet3)
        
      expect(tx).to eq('0100000001da233d8d3a66eed7160d7d0d53433d11c43a6a50594a2c8281da0ccde692b1f6010000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88acffffffff0300093d00000000001976a914b6588798023037135a20583ce2c6610e36c6ead888ac30750000000000001976a9143955d3f58ee2d7b941ff7583de109da70d1b8a6288ac00db1a00000000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac00000000')
    end
    
    
    VCR.use_cassette(the_subject) do
      tx, inputs_to_sign = OnChain::Transaction.create_single_signature_transaction(
        ['myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8'], 
        'mx97L7gTbERp8B7EK7Bk8R7bgnq6zUKAgY', 4000000, 
        30000, 'mkk7dRJz4288ux6kLmFi1w6GcHjJowtFc8', 10000, :testnet3)
        
      expect(tx).to eq('0100000001da233d8d3a66eed7160d7d0d53433d11c43a6a50594a2c8281da0ccde692b1f6010000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88acffffffff0300093d00000000001976a914b6588798023037135a20583ce2c6610e36c6ead888ac30750000000000001976a9143955d3f58ee2d7b941ff7583de109da70d1b8a6288ac00db1a00000000001976a914c2372ca390730d5cb2983736c8aa0959bf9cb9ef88ac00000000')
    end
  end
  
  it "should create a testnet transaction" do
    
    VCR.use_cassette(the_subject) do
      redemption_scripts = ["5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102787adcb5648253eaf437f7fa516c4defbfd2f6fea896cfe2ca644330212390d352ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102835743a35a8bd08cc5c2c9a0a814ff331ec5be9c84883eb0e84f700d605ef30152ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103a0b2c4d3286d5ce538c93bb578e8b25f8e685618d6c0304ec6556393ad873b4c52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72102536c74016e54a5023160960fa739cadf8f031d78d9cb0ceb7922c174cd4e7c2a52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721032a1f697a7bc0b6feaa036e7f08d2ff7674f9dbc3e17ef930d1f7ec10755bc5f852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721034a502facb54118ed072abab32321665bd3ed609fe2a5f63aa687a8a55205efa852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103c287f5d86aac6156b7368fe3c474cef5d9e27e4a0580b55a822ed83e65c43e9852ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103a438065c6dd6c1db7bbd1077828cddb8d1f1322bc21df530214c495d681d19ac52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf72103bc1ba670f47c239bd567f5ffe733e90250b26d21b5d5f35f9aa119081efd4d8d52ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721028bc9fd70333fd6ae9205aed42de5e37ac17b82dc386bdc0d0dec3bca1a28f5c052ae", "5221032c6c755d5da9c9e442bc4fdd08680d27e52b55bdefe8f664e7df2726686a2bf721029770d82c16ef9388620430b14f4c7f078cc456bd5c2c76cb039c9aa67034512d52ae"] 
      
      tx, siglist = OnChain::Transaction.create_transaction(
        redemption_scripts, 'myDsUrM5Sd7SjpnWXnQARyTriVAPfLQbt8', 4000000, 10000, 0, nil, :testnet3)
    end
  end
  
  it "should give me a history for an testnet address" do
  
    VCR.use_cassette(the_subject) do
      hist = OnChain::BlockChain.address_history('2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca', :testnet3)
      
      expect(hist.length).to eq(3)  
    end
  end
  
  it "should get history for addresses on testnet" do
  
    VCR.use_cassette(the_subject) do
      hist = OnChain::BlockChain.get_history_for_addresses(['2MwpZJ67K9s8Q3bdaTziW6u1qWffjXHM7ca'], :testnet3)
      
      expect(hist.length).to eq(3)
    end
  end
  
end
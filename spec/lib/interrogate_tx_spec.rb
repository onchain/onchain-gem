require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
   "interrogate_tx_spec/" +  example.description
  end
  
  it "get recommended transaction fee" do
    VCR.use_cassette(the_subject) do
      fee = OnChain::Transaction.get_recommended_tx_fee["fastestFee"]
      
      expect(fee).to be > 0
    end
  end
  
  it "should estimate transaction sizes" do
    VCR.use_cassette(the_subject) do
      orig_addr = '13H8HWUgyaeMXJoDnKeUFMcXLJbCQ7s7V5'
      
      OnChain::Transaction.estimate_transaction_size([orig_addr], 0.38 * 100_000_000)
    end
  end
  
  it "should calculate the miners fee" do
    
    VCR.use_cassette(the_subject) do
      orig_addr = '1HMTY59ZaVB9L4rh7PjMjEca2fiT1TucGH'
      
      fee = OnChain::Transaction.calculate_miners_fee([orig_addr], 1000000)
      
      expect(fee).to be > 1000
    end
  end
  
  it "should interrogate an ethereum transaction" do
    
      txhex = "0xeb808504a817c80082753094b488665b25c51f0c5838e39164f68b9379f8cd5487038d7ea4c6800000808080"
      
      wallet_addresses = ["0x46FC2341DC457BA023cF6d60Cb0729E5928A81E6	"]
        
      result = OnChain::Transaction.interrogate_transaction(txhex, 
        wallet_addresses, nil, nil, :ethereum)
        
      expect(result[:destination]).to eq("0xB488665B25c51f0c5838E39164f68b9379F8Cd54")
      expect(result[:miners_fee]).to eq(0.0006)
      expect(result[:total_change]).to eq(0)
      expect(result[:total_to_send]).to eq(0.001)
      expect(result[:our_fees]).to eq(0)
      expect(result[:unrecognised_destination]).to eq(nil)
      expect(result[:primary_send]).to eq(0.001)
      
  end
  
  it "should interrogate a bitcoin cash transaction" do
    
    VCR.use_cassette(the_subject) do
      txhex = "0100000001706c1ba9a0dfbd8bd8d462458fe4236a5bbd0cab9910e23784e9834fbfec6aab000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88acffffffff03400d0300000000001976a914450b0ad6d230ce80a820f46ef8288dd4a0cb211988ac0ca80500000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac801a0600000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac00000000"
      
      total_input_value = 1_000_000
      
      wallet_addresses = ["1PWBu8o8pBHXCiVY5Y2Hcg4k8JYHw5Cdut", "1HgjW3C7K6FzDrkTxjas6vAgNwDx37HTHT", "1DbJ2kfB4LEFiWCnBfQtip3qNYeCW4fPCT", "18R8zFCeBpKx4Ckz7CSM9N8X5oZUEdwxeE", "1AnWyweX2bckfM2fBw1CGmxY5ae7W9xNb1", "1P6FY4nGEKk2edjm5VTPJnsyQXHNpdMbmr", "17ZrWrszcwo4NpSDdNE2VJihRxCNoW13Xx", "1Pv4G2RN4RYmoE81GG8P7oiv9XgctSrfrC", "1EDPHrjYeUhxAoWDQ9dWoxCi5MbfTEthNe", "14YmndsixbfKvzDj2EaBvssduhHPcBA71o", "17J4rUMLEa2hw8cLGzF4N8FZCXUzUYQotT"]
        
      result = OnChain::Transaction.interrogate_transaction(txhex, 
        wallet_addresses,
        ['1JXYMviGfEvjYGP2ZGfDJku6EjnPPEgtr6'], total_input_value)
        
      expect(result[:miners_fee]).to eq(0.000293)
      expect(result[:total_change]).to eq(0.004)
      expect(result[:total_to_send]).to eq(0.01)
      expect(result[:our_fees]).to eq(0.003707)
      expect(result[:destination]).to eq("17J4rUMLEa2hw8cLGzF4N8FZCXUzUYQotT")
      expect(result[:unrecognised_destination]).to eq(0.0)
      expect(result[:primary_send]).to eq(0.002)
    end
  end
  
  it "should interrogate a transaction" do
    
    VCR.use_cassette(the_subject) do
      txhex = "01000000016b631e692ec8481265a73a7ce643722c72145049bb0696bb2e8ada67f7a751cb0000000047522103ae9006247d18249116381e0fd1f87df3ce5295995873a81394a9dfb4a96096dd210221b9cb16c1cb3f1d493cbe73f3dd79c8483fd54b7335f5057427a00aacb23ab552aeffffffff0300e1f5050000000017a9140c01e8d5ed4d6de3719e9a11af596bc242bfae698724a00e00000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac89ad2b020000000017a914ca97c2df84cb614feab88f0f6369b1017be80b818700000000"
      
      total_input_value = 137_416_905
      
      result = OnChain::Transaction.interrogate_transaction(txhex, 
        ['3LAEDr9PuQkU2hnKERaHATgJ1SrDdVzWd3'], 
        ['1JXYMviGfEvjYGP2ZGfDJku6EjnPPEgtr6'], total_input_value)
        
      expect(result[:miners_fee]).to eq(0.000415)
      expect(result[:total_change]).to eq(0.36416905)
      expect(result[:total_to_send]).to eq(1.37416905)
      expect(result[:our_fees]).to eq(0.009585)
      expect(result[:destination]).to eq("32nWKXBDkEV8vb2B4ZKR54mwzN897WpCnS")
      expect(result[:unrecognised_destination]).to eq(0.0)
      expect(result[:primary_send]).to eq(1.0)
    end
  end
  
  it "should interrogate an affiliate transaction" do
    
    VCR.use_cassette(the_subject) do
      txhex = "010000000275fe229c43fa1a89412e793bb0048e8cd72cc377c462ae2c4e953811b950f794020000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff0afe22c61aa6ad6b066245ae4fca4f1e2f083e61b3d1c58d17ac3173e9ce7b4b000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788acffffffff04a0860100000000001976a914c040cbbcdbf5cb6a06ffd800b51990381fa8b2df88ac30e60200000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac30e60200000000001976a9147a2e64eec19154ed1792c3b9c07bae900e5e74df88aca0860100000000001976a914bc9efe4aa8d545bb0bf6c4587eca592c101d941788ac00000000"
      
      total_input_value = 600_000
      
      result = OnChain::Transaction.interrogate_transaction(txhex, 
        ['1JCLW7cvVv2aHvcCUc4284unoaKXciftzW'], 
        ['1STRonGxnFTeJiA7pgyneKknR29AwBM77', 
        '1C931w9YKHeogc8N4zRUKSvitoPcTPKPFf'], total_input_value)
        
      expect(result[:miners_fee]).to eq(0.0002)
      expect(result[:total_change]).to eq(0.001)
      expect(result[:total_to_send]).to eq(0.006)
      expect(result[:our_fees]).to eq(0.0038)
      expect(result[:destination]).to eq("1JXYMviGfEvjYGP2ZGfDJku6EjnPPEgtr6")
      expect(result[:unrecognised_destination]).to eq(0.0)
      expect(result[:primary_send]).to eq(0.001)
    end
  end
  
  it "should sanity check a transaction" do
    
    VCR.use_cassette(the_subject) do
      tx = '010000000168e118d870ce6c30a6fc2f857f1a55909a500551e7d441ff368e595ce062dd26020000008a47304402207d687b513ee58c6cb9348613735d20320b74e9c80845db44f8032ec75125a7a5022058bb5f1d705d0b5701583aac690c0ff1b537e5f24342093e8d559b30681c96920141047299bb198fbcd6992000e1557fd63278feb44b313b7a2c4f735ca99fb73e65de24aa9a17858686942e63b4db467f60d50ef77c362b1b50ac6ca2a7eacfe85f3cffffffff03808d5b00000000001976a9141969dd3c9f1765fd923c8c9c1ad52a26410ed12688ac801a0600000000001976a91404d075b3f501deeef5565143282b6cfe8fad5e9488ac40771b00000000001976a914b3607b90aa91452f234d85ec2809d0037e71f38788ac00000000'
      
      orig_addr = '1HMTY59ZaVB9L4rh7PjMjEca2fiT1TucGH'
      dest_addr = ''
      
      amount = 0.82 * 100000000
      
      OnChain::Transaction.check_integrity(tx, amount, [orig_addr], dest_addr, 0.1)
      
      error = nil
      begin
        OnChain::Transaction.check_integrity(tx, 1, [orig_addr], dest_addr, 0.1)
      rescue => e
        error = e.message
      end
      expect(error).to eq("Transaction has more input value (6500000) than the tolerence 1.1")
      
      error = nil
      begin
        OnChain::Transaction.check_integrity(tx, amount, ['1HELLOZaVB9L4rh7PjMjEca2fiT1TucGH'], dest_addr, 0.1)
      rescue => e
        error = e.message
      end
      expect(error).to eq("One of the inputs is not from from our list of valid originating addresses")
    end
  end
  
end
require 'spec_helper'

describe OnChain do
  
  subject(:the_subject) do |example|
     "bitcoin_private_spec/" + example.description
  end
  
  it "shoud pull aprt a working bitocin priuvate tx" do
    
    johns_tx = "010000000129d0eebba829bc4fc616362e78c87a77248e30feec4e5a48c4380b4831b4cb90000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88acffffffff0320a10700000000001976a9143a48bfebcdc52c7b3831eab75a1955e58744c7e388ac0ca80500000000001976a9148a1dde437f546b20222b4a4434c8b9dd4d8b05ba88acc0b7d903000000001976a914f6d7ed94dc8eb238c7347fc0120bf7cd9db5bb7b88ac00000000"
    raw_tx = "0100000001de5f22267d5bab37056c350c77e2205088b6ae07256ebc6f4f62d55aafe57460000000006b483045022100f82d1f1d42fb98b3969cb6f9e61f81c6df4644db2d3c1c25590375820de66a3e02203143cb86bf6ccf8acb41bad06cc34ae7ce36ee71afdfef60ff4b2243fada58464121037792c39eb69d126bf0860739f8ce8fdc4bf0385f3f61366df218d461211d7848fdffffff0264e10000000000001976a914c3a0de2709217d56a63f5e493d360125a04df94f88aca0bb0d00000000001976a914e217172318431eb8eceeeff1c160bfbfaf55b13c88acda4b0400"
    
    tx = Bitcoin::Protocol::Tx.new(raw_tx)
    
    #puts tx.in[0]
    
    puts tx.in[0].parsed_script.to_string
    
    puts tx.in[0].parsed_script.is_witness?
    
    #puts tx.in[0].to_hash
    #puts tx.in.size #=> 4
    #puts tx.out.size #=> 2
    #puts 'hash ' + tx.hash 
    tx = Bitcoin::Protocol::Tx.new(johns_tx)
    
    puts
    
   # puts tx.in[0]
    
    puts tx.in[0].parsed_script.to_string
    
    #puts tx.in[0].to_hash
  end
  
  it "should be able to retrieve a balance." do
    
    VCR.use_cassette(the_subject) do  
      
      # Insight API
      test1 =  OnChain::BlockChain.get_balance(
        'b1SyPaKe8ZLKdKzp72gTGDB3RkaFN8SQK9N', :bitcoin_private)
      
      
      expect(test1).to eq(32.66721836)
    end
    
  end
  
  it "should create and sign a valid bitcoin private transaction." do
    
    wif = 'L1BaRvRHhVVtq3AAWRCdaa1QJFHFpoQXXiyoLWoBurf7UznREdNw'
    
    public_key = OnChain::Address.address_from_wif(wif, :bitcoin_private)
      
    expect(public_key).to eq('b17e5xisoAzgwr5ZQ7k9h7NQyKgSnhm7WeC')
    #VCR.use_cassette(the_subject) do
       
    #end
    
  end
end
class OnChain
  class << self
    
    
    # With a bunch of HD wallet paths, build a transaction
    # That pays all the coins to a certain address
    def create_payment_tx(fund_address, payments)
      
      begin
        
        tx = Bitcoin::Protocol::Tx.new
      
        total_amount = 0  
      
        payments.each do |payment|
          if payment[1].is_a?(String)
            payment[1] = payment[1].to_i
          end
          total_amount = total_amount + payment[1]
        end
      
        total_in_fund = get_balance_satoshi(fund_address)
        
        # Do we have enough in the fund.
        if(total_amount > total_in_fund)
          return 'Balance is not enough to cover payment'
        end
        
        # OK, let's get some inputs
        amount_so_far = 0
        unspent = get_unspent_outs(fund_address)
        unspent.each do |spent|
          
          amount_so_far = amount_so_far + spent[3].to_i
          if amount_so_far >= total_amount
            next
          end
          
          txin = Bitcoin::Protocol::TxIn.new

          txin.prev_out = spent[0]
          txin.prev_out_index = spent[1]
      
          tx.add_in(txin)
        end
        change = amount_so_far - total_amount
        
        payments.each do |payment|
          txout = Bitcoin::Protocol::TxOut.new(payment[1], Bitcoin::Script.from_string(
            "OP_DUP OP_HASH160 #{payment[0]} " + 
            "OP_EQUALVERIFY OP_CHECKSIG").to_payload)
      
          tx.add_out(txout)
        end
        
        return tx
        
      rescue Exception => e
        return 'Unable to parse payment :: ' + e.to_s
      end
    end
    
  end
end
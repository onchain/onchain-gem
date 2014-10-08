class OnChain
  class << self
    
    FEE = 50000
    
    def get_address_from_redemption_script(redemption_script)
      
      sbin = redemption_script.scan(/../).map { |x| x.hex }.pack('c*')
      hex = sbin.unpack("H*")[0]
      fund_address = Bitcoin.hash160_to_p2sh_address(Bitcoin.hash160(hex))
      
      return fund_address
    end
    
    def hex_to_script(hex)
      sbin = hex.scan(/../).map { |x| x.hex }.pack('c*')
      return Bitcoin::Script.new(sbin)
    end
    
    # With a bunch of HD wallet paths, build a transaction
    # That pays all the coins to a certain address
    def create_payment_tx(redemption_script, payments)
      
      begin
        
        fund_address = get_address_from_redemption_script(redemption_script)
        
        tx = Bitcoin::Protocol::Tx.new
      
        total_amount = FEE  
      
        payments.each do |payment|
          if payment[1].is_a?(String)
            payment[1] = payment[1].to_i
          end
          total_amount = total_amount + payment[1]
        end
      
        total_in_fund = OnChain::BlockChain.get_balance_satoshi(fund_address)
        
        # Do we have enough in the fund.
        if(total_amount > total_in_fund)
          return 'Balance is not enough to cover payment'
        end
        
        # OK, let's get some inputs
        amount_so_far = 0
        unspent = OnChain::BlockChain.get_unspent_outs(fund_address)
        unspent.each do |spent|

          txin = Bitcoin::Protocol::TxIn.new

          txin.prev_out = spent[0].scan(/../).map { |x| x.hex }.pack('c*').reverse
          txin.prev_out_index = spent[1]
          txin.script = hex_to_script(redemption_script).to_payload
      
          tx.add_in(txin)
          
          amount_so_far = amount_so_far + spent[3].to_i
          if amount_so_far >= total_amount
            next
          end
        end
        change = amount_so_far - total_amount
        
        payments.each do |payment|
          
          txout = Bitcoin::Protocol::TxOut.new(payment[1], 
            Bitcoin::Script.to_address_script(payment[0]))
      
          tx.add_out(txout)
        end
        
        # Send the chnage back.
        if total_in_fund > total_amount
          
          txout = Bitcoin::Protocol::TxOut.new(total_in_fund - total_amount, 
            Bitcoin::Script.to_address_script(fund_address))
      
          tx.add_out(txout)
        end
        
        return tx
        
      rescue Exception => e
        return 'Unable to parse payment :: ' + e.to_s
      end
    end
    
  end
end
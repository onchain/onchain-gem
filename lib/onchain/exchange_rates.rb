require 'httparty'
require 'cgi'
require 'money'
require 'money/bank/google_currency'

class OnChain::ExchangeRate

  class << self
    
    BALANCE_RATE_FOR = 120

    def exchange_rate(currency)
      begin
        ticker = "BTC-" + currency.to_s

        if OnChain::BlockChain.cache_read(ticker) == nil
          if currency == :USD 
            begin
              r = HTTParty.get("https://www.bitstamp.net/api/ticker/")    
              j = JSON.parse r.response.body   
              rate = j["last"]
              OnChain::BlockChain.cache_write(ticker, rate, BALANCE_RATE_FOR)
            rescue
              r = HTTParty.get("https://blockchain.info/ticker")
              j = JSON.parse r.response.body
              OnChain::BlockChain.cache_write(ticker, j["USD"]["last"], BALANCE_RATE_FOR)
            end

          elsif currency == :EUR

            Money.default_bank = Money::Bank::GoogleCurrency.new
            
            btc_usd = exchange_rate(:USD).to_f
            
            money = Money.new(1_00, "USD") 
            
            usd_eur = money.exchange_to(:EUR).to_f
            
            rate = usd_eur * btc_usd

            OnChain::BlockChain.cache_write(ticker, rate.to_s, BALANCE_RATE_FOR)

          elsif currency == :GBP

            Money.default_bank = Money::Bank::GoogleCurrency.new
            
            btc_usd = exchange_rate(:USD).to_f
            
            money = Money.new(1_00, "USD") 
            
            usd_gbp = money.exchange_to(:GBP).to_f
            
            rate = usd_gbp * btc_usd

            OnChain::BlockChain.cache_write(ticker, rate.to_s, BALANCE_RATE_FOR)

          else
            OnChain::BlockChain.cache_write(ticker, "0", BALANCE_RATE_FOR)
          end

        end
        return OnChain::BlockChain.cache_read(ticker) 
      rescue Exception => e
        puts e.to_s
        '0'
      end

    end

  end

end

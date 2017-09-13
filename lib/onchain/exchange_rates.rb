require 'money'
require 'money/bank/google_currency'

class OnChain::ExchangeRate

  class << self
    
    BALANCE_RATE_FOR = 120
    
    def bitcoin_exchange_rate(currency)
      return exchange_rate(currency, :bitcoin) 
    end

    def exchange_rate(currency, network = :bitcoin)
      begin
        ticker = network.to_s + "-" + currency.to_s

        if OnChain::BlockChain.cache_read(ticker) == nil
          if currency == :USD 
            
            coin_market_ticker = case network
              when :bitcoin_cash then 'bitcoin-cash'
              when :bitcoin then 'bitcoin'
              when :zcash then 'zcash'
              when :zclassic then 'zclassic'
              when :etherum then 'ethereum'
              else nil
            end
            
            if coin_market_ticker == nil
              return 0.0
            end
            
            url = 'https://api.coinmarketcap.com/v1/ticker/' + coin_market_ticker + '/'
            
            begin
              r = OnChain::BlockChain.fetch_response(url)   
              rate = r[0]['price_usd'].to_f
              OnChain::BlockChain.cache_write(ticker, rate, BALANCE_RATE_FOR)
            rescue
              return 0.0
            end

          elsif currency == :EUR

            Money.default_bank = Money::Bank::GoogleCurrency.new
            
            btc_usd = bitcoin_exchange_rate(:USD).to_f
            
            money = Money.new(1_00, "USD") 
            
            usd_eur = money.exchange_to(:EUR).to_f
            
            rate = usd_eur * btc_usd

            OnChain::BlockChain.cache_write(ticker, rate.to_s, BALANCE_RATE_FOR)

          elsif currency == :GBP

            Money.default_bank = Money::Bank::GoogleCurrency.new
            
            btc_usd = bitcoin_exchange_rate(:USD).to_f
            
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

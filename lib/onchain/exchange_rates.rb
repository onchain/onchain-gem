
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
              when :ethereum then 'ethereum'
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

          else 
          
            url = 'https://api.fixer.io/latest?base=USD'
            
            begin
              r = OnChain::BlockChain.fetch_response(url)   
              usd_eur = r['rates'][currency.to_s].to_f 
              
              btc_usd = bitcoin_exchange_rate(:USD).to_f
            
              rate = usd_eur * btc_usd

              OnChain::BlockChain.cache_write(ticker, rate.to_s, BALANCE_RATE_FOR)

            rescue
              return 0.0
            end
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

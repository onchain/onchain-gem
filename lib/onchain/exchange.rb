class OnChain::Exchange

  class << self
    
    def get_min_amount(from, to)
      
      puts
      
      message = {
        "jsonrpc": "2.0",
        "id": 1,
        "method": "getMinAmount",
        "params": [ from: 'eth', to: 'btc' ]
      }

      return fetch_response(message.to_json)
    end
    
    def fetch_response(message)
      
      uri = URI.parse('https://api.changelly.com/')
      
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      digest = OpenSSL::Digest.new('sha512')
      
      signature = OpenSSL::HMAC.digest(digest, ENV['CHANGELLY_SECRET_KEY'], message)
      
      sig = OnChain.bin_to_hex signature
      
      request = Net::HTTP::Post.new("/")
      request.add_field('Content-Type', 'application/json')
      request.add_field('api-key', ENV['CHANGELLY_API_KEY'])
      request.add_field('sign', sig)
      request.body = message
      response = http.request(request)
      
      return JSON.parse response.body
    end
  end
end
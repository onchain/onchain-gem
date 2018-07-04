# -*- encoding: utf-8 -*-
require File.expand_path('../lib/onchain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Number 6"]
  gem.email         = ["support@onchain.io"]
  gem.summary       = %q{Ruby wrapper for various 3rd-party bitcoin APIs}
  gem.description   = %q{Call 3rd party API's but also switch API's if a 3rd party is down}
  gem.homepage      = "https://github.com/onchain/onchain-gem"

  gem.files         = ["lib/onchain.rb", "lib/onchain/block_chain.rb", 
                      "lib/onchain/transaction.rb",
                      "lib/onchain/exchange_rates.rb",
                      "lib/onchain/address.rb",
                      "lib/onchain/providers/blockchaininfo_api.rb",
                      "lib/onchain/providers/insight_api.rb",
                      "lib/onchain/providers/bitcoind_api.rb",
                      "lib/onchain/providers/etherchain_api.rb",
                      "lib/onchain/providers/etherscan_api.rb",
                      "lib/onchain/providers/ethereum_blockcypher_api.rb",
                      "lib/onchain/providers/blockr_api.rb"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "onchain"
  gem.require_paths = ["lib"]
  gem.version       = Onchain::VERSION
  
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'vcr'
  gem.add_development_dependency 'webmock'
  gem.add_development_dependency 'rspec', '~> 3.1.0'

  gem.add_dependency 'money-tree'
  gem.add_dependency 'bitcoin-ruby'
  gem.add_dependency 'eth'
  gem.add_dependency 'blake2'
end
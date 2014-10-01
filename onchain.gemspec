# -*- encoding: utf-8 -*-
require File.expand_path('../lib/onchain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ian Purton"]
  gem.email         = ["ian@onchain.com"]
  gem.summary       = %q{Ruby wrapper for various 3rd-party bitcoin APIs}
  gem.description   = %q{Call 3rd party API's but also switch API's if a 3rd party is down}
  gem.homepage      = "https://github.com/onchain/onchain-gem"

  gem.files         = ["lib/onchain.rb", "lib/onchain/block_chain.rb", "lib/onchain/sweeper.rb"]
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "onchain"
  gem.require_paths = ["lib"]
  gem.version       = Onchain::VERSION
  
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'

  gem.add_dependency 'money-tree'
end
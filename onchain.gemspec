# -*- encoding: utf-8 -*-
require File.expand_path('../lib/onchain/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ian Purton"]
  gem.email         = ["ian@onchain.com"]
  gem.summary       = %q{Ruby wrapper for various 3rd-party bitcoin APIs}
  gem.description   = %q{Call 3rd party API's but also switch API's if a 3rd party is down}
  gem.homepage      = "https://github.com/onchain/onchain-gem"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "onchain"
  gem.require_paths = ["lib"]
  gem.version       = OnchainGem::VERSION
  
  %w{rspec vcr ir_b guard-rspec webmock}.each do |gem_library|
    gem.add_development_dependency gem_library
  end
end
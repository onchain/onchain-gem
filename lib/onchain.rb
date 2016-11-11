require 'onchain/block_chain.rb'
require 'onchain/providers/blockchaininfo_api.rb'
require 'onchain/providers/blockr_api.rb'
require 'onchain/providers/insight_api.rb'
require 'onchain/providers/bitcoind_api.rb'
require 'onchain/transaction.rb'
require 'onchain/exchange_rates.rb'
require 'money-tree'
require 'bitcoin'

# Setup the bitcoin gem for zcash
module Bitcoin

  NETWORKS[:zcash_testnet] = NETWORKS[:testnet3].merge({
      address_version: "1D25",
      p2sh_version: "1CBA"
  })

  NETWORKS[:zcash] = NETWORKS[:bitcoin].merge({
      address_version: "1CB8",
      p2sh_version: "1CBD"
  })

  NETWORKS[:zclassic] = NETWORKS[:bitcoin].merge({
      address_version: "1CB8",
      p2sh_version: "1CBD"
  })

end

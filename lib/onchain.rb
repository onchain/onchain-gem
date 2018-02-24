class OnChain
end

require 'onchain/providers/blockchaininfo_api.rb'
require 'onchain/providers/blockr_api.rb'
require 'onchain/providers/insight_api.rb'
require 'onchain/providers/bitcoind_api.rb'
require 'onchain/providers/etherchain_api.rb'
require 'onchain/providers/ethereum_blockcypher_api.rb'
require 'onchain/address.rb'
require 'onchain/block_chain.rb'
require 'onchain/transaction.rb'
require 'onchain/ethereum.rb'
require 'onchain/exchange_rates.rb'
require 'money-tree'
require 'bitcoin'
require 'eth'

# Setup the bitcoin gem for zcash
module Bitcoin
  
  # To add a new currency also update the exchange rate code.

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

  NETWORKS[:bitcoin_cash] = NETWORKS[:bitcoin].merge({
    fork_id: 0
  })

  NETWORKS[:bitcoin_gold] = NETWORKS[:bitcoin].merge({
    fork_id: 64
  })
  

end

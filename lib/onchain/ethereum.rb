class OnChain::Ethereum
  class << self
    
    def create_single_address_transaction(orig_addr, dest_addr, amount)

      tx = Eth::Tx.new({
        data: '00',
        gas_limit: 3_141_592,
        gas_price: 20_000_000_000,
        nonce: 1,
        to: dest_addr,
        value: amount,
      })

      #inputs_to_sign = get_inputs_to_sign(tx, unspents, network)
      hash_hex = Eth::Utils.bin_to_hex (Eth::Utils.keccak256 tx.unsigned_encoded)
      return tx.hex, hash_hex
    end
  end
  
end
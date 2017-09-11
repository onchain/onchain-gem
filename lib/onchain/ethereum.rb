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
      
      inputs_to_sign = []
      
      hash_hex = Eth::Utils.bin_to_hex (Eth::Utils.keccak256 tx.unsigned_encoded)
      inputs_to_sign << { 'hash' => hash_hex }

      return tx.hex, inputs_to_sign
    end
  end
  
end
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
    
    def finish_single_address_transaction(orig_addr, dest_addr, amount, r, s ,v)
  
      # Reconstruct it and sign it.
      tx = Eth::Tx.new({
        data: '00',
        gas_limit: 3_141_592,
        gas_price: 20_000_000_000,
        nonce: 1,
        to: dest_addr,
        value: amount,
        v: v,
        s: s.to_i(16),
        r: r.to_i(16)
      })
      
      return tx
    
    end
  end
  
end
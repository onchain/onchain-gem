class OnChain::Ethereum
  class << self
    
    GAS_LIMIT = 30_000
    GAS_PRICE = (0.00000002 * 1_000_000_000_000_000_000).to_i
    
    def create_single_address_transaction(orig_addr, dest_addr, amount, 
      gas_price = GAS_PRICE, gas_limit = GAS_LIMIT)
      
      nonce = OnChain::BlockChain.get_nonce(orig_addr)

      tx = Eth::Tx.new({
        data: '00',
        gas_limit: gas_limit,
        gas_price: gas_price,
        nonce: nonce + 1,
        to: dest_addr,
        value: amount,
      })
      
      inputs_to_sign = []
      
      hash_hex = Eth::Utils.bin_to_hex (Eth::Utils.keccak256 tx.unsigned_encoded)
      inputs_to_sign << { 'hash' => hash_hex }

      return tx.hex, inputs_to_sign
    end
    
    def finish_single_address_transaction(orig_addr, dest_addr, amount, r, s ,v, 
      gas_price = GAS_PRICE, gas_limit = GAS_LIMIT)
  
      nonce = OnChain::BlockChain.get_nonce(orig_addr)
      
      # Reconstruct it and sign it.
      tx = Eth::Tx.new({
        data: '00',
        gas_limit: gas_limit,
        gas_price: gas_price,
        nonce: nonce + 1,
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
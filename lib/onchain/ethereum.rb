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
        nonce: nonce,
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
        nonce: nonce,
        to: dest_addr,
        value: amount,
        v: v,
        s: s.to_i(16),
        r: r.to_i(16)
      })
      
      return tx
    
    end
    
    ERC20_TRANSFER_ABI = 'transfer(address,uint256)'
    
    def create_token_transfer(orig_addr, destination_addr, contract_addr, 
      amount, decimal_places, gas_price = GAS_PRICE, gas_limit = GAS_LIMIT)
      
      nonce = OnChain::BlockChain.get_nonce(orig_addr)
      
      data = erc20_transfer_data(destination_addr, amount, decimal_places)

      tx = Eth::Tx.new({
        data: data,
        gas_limit: gas_limit,
        gas_price: gas_price,
        nonce: nonce,
        to: contract_addr,
        value: 0,
      })
      
      inputs_to_sign = []
      
      hash_hex = Eth::Utils.bin_to_hex (Eth::Utils.keccak256 tx.unsigned_encoded)
      inputs_to_sign << { 'hash' => hash_hex }

      return tx.hex, inputs_to_sign
    end
  
    private 
    
    def erc20_transfer_data(destination_addr, amount, decimal_places)
        
        # The function selector is the first four bytes of the keccak-256 hash of 
        # the canonical function signature.
        function_selector = Eth::Utils.bin_to_hex(
          Eth::Utils.keccak256 ERC20_TRANSFER_ABI)[0..7]
  
        destination_padded = Eth::Utils.remove_hex_prefix destination_addr.downcase  
        destination_padded = destination_padded.rjust(64, '0')
        
        amount_padded_32 = (amount * (10 ** decimal_places)).to_s(16)
        amount_padded_32 = amount_padded_32.rjust(64, '0')
        
        return function_selector + destination_padded + amount_padded_32
    end
    
  end
  
end
module Bitcoin
  module Protocol

    class Tx
      
      # Factory methods
      def self.create_for_network(network)
        tx = Bitcoin::Protocol::Tx.new
        if network == :zcash
          tx.ver = 3
          tx.version_group_id = '0x03c48270'
          tx.expiry_height = 0
        end
        return tx
      end
      
      def self.create_from_hex(tx_hex, network = :bitcoin)
        if network == :zcash
          return parse_zcash_from_hex(tx_hex)
        end
        return Bitcoin::Protocol::Tx.new OnChain::hex_to_bin(tx_hex)
      end
        
      # output transaction in raw binary format
      def to_network_payload(network)
        if network == :zcash
          return to_zcash_payload
        end
        witness? ? to_witness_payload : to_old_payload
      end
      
      def get_inputs_to_sign(unspents, network = :bitcoin)
        inputs_to_sign = []
        
        @in.each_with_index do |txin, index|
  
  
          if network == :zcash
  
            # ZCash
            script_code = Bitcoin::Protocol.pack_var_string(txin.script)
            sig_hash =  Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all] 
            hash = signature_hash_for_zcash(index, script_code, 
              unspents[index][3], sig_hash)
  
          elsif Bitcoin::NETWORKS[network][:fork_id] == nil
  
            # The Bitcoin and statndard forks implement the hash
            hash = signature_hash_for_input(index, txin.script, 
              Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all])
          elsif network == :bitcoin_private
  
            # Bitcoin private
            sig_hash = Bitcoin::Protocol::Tx::SIGHASH_TYPE[:forkid] | 
              Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all] 
            hash = signature_hash_for_bitcoin_private_input(index, txin.script, 
              sig_hash, Bitcoin::NETWORKS[network][:fork_id])
  
          else
            # Replay protection as used by bitcoin cash and bitcoin gold
  
            sig_hash = Bitcoin::Protocol::Tx::SIGHASH_TYPE[:forkid] | 
              Bitcoin::Protocol::Tx::SIGHASH_TYPE[:all] 
          
            # This is not implemented in bitcoin ruby 
            # see https://github.com/lian/bitcoin-ruby/blob/05eae36cf04b0dd426930dbea34d48769272f9d2/lib/bitcoin/protocol/tx.rb#L188
            #hash = tx.signature_hash_for_input(index, txin.script, 
            #  sig_hash, unspents[index][3], Bitcoin::NETWORKS[network][:fork_id])
            
            script_code = Bitcoin::Protocol.pack_var_string(txin.script)
            hash = signature_hash_with_a_fork_id(index, script_code, 
              unspents[index][3], sig_hash, Bitcoin::NETWORKS[network][:fork_id])
          end
          
          script = Bitcoin::Script.new txin.script
          
          pubkeys = Bitcoin::Protocol::Tx.get_public_keys_from_script(script)
          pubkeys.each do |key|
            
            if inputs_to_sign[index] == nil
              inputs_to_sign[index] = {}
            end
            inputs_to_sign[index][key] = {'hash' => OnChain::bin_to_hex(hash)}
          end
        end
        return inputs_to_sign
      end
      
      
    
      def self.get_public_keys_from_script(script)
    
        if script.is_hash160?
          return [Bitcoin.hash160_to_address(script.get_hash160)]
        end
        
        pubs = []
        script.get_multisig_pubkeys.each do |pub|
          pubs << OnChain.bin_to_hex(pub)
        end
        return pubs
      end
      
    end
    
  end
  
end
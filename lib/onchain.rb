class OnChain
end

require 'onchain/providers/blockchaininfo_api.rb'
require 'onchain/providers/blockr_api.rb'
require 'onchain/providers/insight_api.rb'
require 'onchain/providers/bitcoind_api.rb'
require 'onchain/block_chain.rb'
require 'onchain/transaction.rb'
require 'onchain/exchange_rates.rb'
require 'money-tree'
require 'bitcoin'

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
  })
  
  # Bitcoin ruby doens't support Bitcoin Cash, so we monkey path in the 
  # FORKID hash code.
  module Protocol
      
    Tx::SIGHASH_TYPE[:forkid] = 64
    
    class Tx
    
      # generate a witness signature hash for input +input_idx+.
      # https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
      def signature_hash_for_cash_input(input_idx, witness_program, prev_out_value, hash_type=nil)
        return "\x01".ljust(32, "\x00") if input_idx >= @in.size # ERROR: SignatureHash() : input_idx=%d out of range

        hash_type ||= SIGHASH_TYPE[:all]

        hash_prevouts = Digest::SHA256.digest(Digest::SHA256.digest(@in.map{|i| [i.prev_out_hash, i.prev_out_index].pack("a32V")}.join))
        
        hash_sequence = Digest::SHA256.digest(Digest::SHA256.digest(@in.map{|i|i.sequence}.join))
        
        script_code = Bitcoin::Protocol.pack_var_string(witness_program)
        
        outpoint = [@in[input_idx].prev_out_hash, @in[input_idx].prev_out_index].pack("a32V")
        amount = [prev_out_value].pack("Q")
        nsequence = @in[input_idx].sequence

        hash_outputs = Digest::SHA256.digest(Digest::SHA256.digest(@out.map{|o|o.to_payload}.join))
        
        case (hash_type & 0x1f)
          when SIGHASH_TYPE[:single]
            hash_outputs = input_idx >= @out.size ? "\x00".ljust(32, "\x00") : Digest::SHA256.digest(Digest::SHA256.digest(@out[input_idx].to_payload))
            hash_sequence = "\x00".ljust(32, "\x00")
          when SIGHASH_TYPE[:none]
            hash_sequence = hash_outputs = "\x00".ljust(32, "\x00")
        end

        if (hash_type & SIGHASH_TYPE[:anyonecanpay]) != 0
          hash_prevouts = hash_sequence ="\x00".ljust(32, "\x00")
        end

        buf = [ [@ver].pack("V"), hash_prevouts, hash_sequence, outpoint,
                script_code, amount, nsequence, hash_outputs, [@lock_time, hash_type].pack("VV")].join

        final = Digest::SHA256.digest( Digest::SHA256.digest( buf ) )
        
        return final
      end
    end
  end

end

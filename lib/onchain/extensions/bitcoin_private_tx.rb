module Bitcoin
  module Protocol

    class Tx
    
      # Bitcoin Private way of hashing inputs for signing
      def signature_hash_for_bitcoin_private_input(input_idx, subscript, 
        hash_type, fork_id)
        # https://github.com/BTCPrivate/BitcoinPrivate/blob/master/src/script/interpreter.cpp#L1102
        # https://github.com/BTCGPU/BTCGPU/blob/master/src/script/interpreter.cpp#L1212
        # https://github.com/BTCPrivate/BitcoinPrivate/blob/master/src/script/interpreter.cpp#L1047
  
        hash_type ||= SIGHASH_TYPE[:all]
        
        # This is what we useds to do.
        #pin  = tx.in.map.with_index{|input,idx|
        #  subscript = subscript.out[ input.prev_out_index ].script if 
        #    subscript.respond_to?(:out) # legacy api (outpoint_tx)
        #
        #  # Remove all instances of OP_CODESEPARATOR from the script.
        #  parsed_subscript = Bitcoin::Script.new(subscript)
        #  parsed_subscript.chunks.delete(Bitcoin::Script::OP_CODESEPARATOR)
        #  subscript = parsed_subscript.to_binary
        #
        #  input.to_payload(subscript)
        #}
  
        #for (unsigned int nInput = 0; nInput < nInputs; nInput++)
        #       SerializeInput(s, nInput, nType, nVersion);
        pin  = @in.map.with_index{|input,idx|
          if idx == input_idx
            subscript = subscript.out[ input.prev_out_index ].script if subscript.respond_to?(:out) # legacy api (outpoint_tx)
  
            # Remove all instances of OP_CODESEPARATOR from the script.
            parsed_subscript = Bitcoin::Script.new(subscript)
            parsed_subscript.chunks.delete(Bitcoin::Script::OP_CODESEPARATOR)
            subscript = parsed_subscript.to_binary
  
            input.to_payload(subscript)
          else
            case (hash_type & 0x1f)
            when Bitcoin::Script::SIGHASH_TYPE[:none];   input.to_payload("", "\x00\x00\x00\x00")
            when Bitcoin::Script::SIGHASH_TYPE[:single]; input.to_payload("", "\x00\x00\x00\x00")
            else;                       input.to_payload("")
            end
          end
        }
  
        #for (unsigned int nOutput = 0; nOutput < nOutputs; nOutput++)
        #       SerializeOutput(s, nOutput, nType, nVersion);
        pout = @out.map(&:to_payload)
        
        in_size = Bitcoin::Protocol.pack_var_int(@in.size)
        out_size = Bitcoin::Protocol.pack_var_int(@out.size)
  
        fork_hash_type = hash_type
        fork_hash_type |= fork_id << 8
  
        buf = [ [@ver].pack("V"),       # ::Serialize(s, txTo.nVersion, nType, nVersion);
          in_size,                        # unsigned int nInputs = fAnyoneCanPay ? 1 : txTo.vin.size();
          pin, 
          out_size,                       # unsigned int nOutputs = fHashNone ? 0 : (fHashSingle ? nIn+1 : txTo.vout.size());
          pout, 
          [@lock_time].pack("V"),
          [fork_hash_type].pack("V") 
        ].join
  
        Digest::SHA256.digest( Digest::SHA256.digest( buf ) )
      end
    end
    
  end
  
end
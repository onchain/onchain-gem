module Bitcoin
  module Protocol

    class Tx
      
      attr_accessor :expiry_height
      attr_accessor :version_group_id
      
      # Zcash
      ZCASH_PREVOUTS_HASH_PERSONALIZATION   = 'ZcashPrevoutHash'
      ZCASH_SEQUENCE_HASH_PERSONALIZATION   = 'ZcashSequencHash'
      ZCASH_OUTPUTS_HASH_PERSONALIZATION    = 'ZcashOutputsHash'
      ZCASH_JOINSPLITS_HASH_PERSONALIZATION = 'ZcashJSplitsHash'
      ZCASH_SIG_HASH_PERSONALIZATION        = 'ZcashSigHash'
      
      def to_zcash_payload
        pin = ""
        @in.each{|input| pin << input.to_payload }
        pout = ""
        @out.each{|output| pout << output.to_payload }

        version           = [@ver | 0x80000000].pack("V")
        version_group_id  = [0x03c48270].pack("V")
  
        # https://github.com/zcash/zips/blob/master/zip-0202.rst
        buf = [          
          version,
          version_group_id,
          Protocol.pack_var_int(@in.size),
          pin,
          Protocol.pack_var_int(@out.size),
          pout,
          [@lock_time].pack("V"),
          [@expiry_height].pack("V"),
          Protocol.pack_var_int(0) # Number of join splits
        ].join
        
        return buf
      
      end
      
      # parse raw binary data
      def self.parse_zcash_from_hex(tx_hex)
        
        tx = Bitcoin::Protocol::Tx.new
        
        data = OnChain::hex_to_bin(tx_hex)
        buf = data.is_a?(String) ? StringIO.new(data) : data

        tx.ver = buf.read(4).unpack("V")[0]
        tx.version_group_id = buf.read(4).unpack("V")[0]

        in_size = Protocol.unpack_var_int_from_io(buf)

        in_size.times{
          break if buf.eof?
          tx.add_in TxIn.from_io(buf)
        }

        return false if buf.eof?

        out_size = Protocol.unpack_var_int_from_io(buf)
        out_size.times{
          break if buf.eof?
          tx.add_out TxOut.from_io(buf)
        }

        return false if buf.eof?

        tx.lock_time = buf.read(4).unpack("V")[0]
        tx.expiry_height = buf.read(4).unpack("V")[0]

        return tx
      end
    
      # ZCash over winter.
      #
      # https://github.com/zcash/zips/blob/master/zip-0143.rst
      #
      def signature_hash_for_zcash(input_idx, script_code, prev_out_value, 
        hash_type, serialize_input = true)
       
        hash_prevouts = OnChain::hex_to_bin(zcash_prev_out_hash)
        
        hash_sequence = OnChain::hex_to_bin(zcash_sequence_hash)
        
        hash_outputs = OnChain::hex_to_bin(zcash_outputs_hash)
          
        hash_joins        = OnChain::hex_to_bin("0" * 64)
        hash_type         = [hash_type].pack("V")
        lock_time         = [@lock_time].pack("V")
        expiry_height     = [@expiry_height].pack("V")
        version           = [@ver | 0x80000000].pack("V")
        version_group_id  = [0x03c48270].pack("V")
  
        buf = [ 
          version,                                  # 1. nVersion | fOverwintered
          version_group_id,                         # 2. nVersionGroupId
          hash_prevouts,                            # 3. hashPrevouts
          hash_sequence,                            # 4. hashSequence
          hash_outputs,                             # 5. hashOutputs
          hash_joins,                               # 6. hashJoinSplits
          lock_time,                                # 7. nLockTime
          expiry_height,                            # 8. expiryHeight
          hash_type                                 # 9. nHashType
        ].join
        
        in_buf_hex = ''
        
        # If we are serializing an input
        if serialize_input
          
          outpoint = [@in[input_idx].prev_out_hash, 
            @in[input_idx].prev_out_index].pack("a32V")
            
          amount = [prev_out_value].pack("Q")
          
          nsequence = @in[input_idx].sequence
        
          inp_buf = [
            outpoint,                                 # 10a. outpoint
            script_code,                              # 10b. scriptCode
            amount,                                   # 10c. value
            nsequence                                 # 10d. nSequence
          ].join
          
          in_buf_hex = OnChain::bin_to_hex(inp_buf)
        end
        
        buffer_hex = OnChain::bin_to_hex(buf) + in_buf_hex
        
        #puts OnChain::bin_to_hex(version) + "\t\t\t\t\t\t\t\t\t# 1. nVersion | fOverwintered"
        #puts OnChain::bin_to_hex(version_group_id) + "\t\t\t\t\t\t\t\t\t# 2. nVersionGroupId"
        #puts OnChain::bin_to_hex(hash_prevouts) + "\t\t# 3. hashPrevouts"
        #puts OnChain::bin_to_hex(hash_sequence) + "\t\t# 4. hashSequence"
        #puts OnChain::bin_to_hex(hash_outputs) + "\t\t# 5. hash_outputs"
        #puts OnChain::bin_to_hex(hash_joins) + "\t\t# 6. hashJoinSplits"
        #puts OnChain::bin_to_hex(lock_time) + "\t\t\t\t\t\t\t\t\t# 7. nLockTime"
        #puts OnChain::bin_to_hex(hash_type) + "\t\t\t\t\t\t\t\t\t# 9. nHashType"
        #puts OnChain::bin_to_hex(outpoint) + "\t# 10a. outpoint"
        #puts OnChain::bin_to_hex(script_code) + "\t\t\t\t# 10b. scriptCode"
        #puts OnChain::bin_to_hex(amount) + "\t\t\t\t\t\t\t\t# 10c. value"
        #puts OnChain::bin_to_hex(nsequence) + "\t\t\t\t\t\t\t\t\t# 10d. nSequence"
  
        blake_hex = OnChain.blake2b(buffer_hex, ZCASH_SIG_HASH_PERSONALIZATION)
        
        return OnChain::hex_to_bin(blake_hex)
      end
      
      def zcash_prev_out_hash
        prev_outs_bin = @in.map{|i| [i.prev_out_hash, i.prev_out_index].pack("a32V")}.join
        OnChain.blake2b(OnChain::bin_to_hex(prev_outs_bin), ZCASH_PREVOUTS_HASH_PERSONALIZATION)
      end
      
      def zcash_sequence_hash
        sequence_bin = @in.map{|i|i.sequence}.join
        OnChain.blake2b(OnChain::bin_to_hex(sequence_bin), ZCASH_SEQUENCE_HASH_PERSONALIZATION)
      end
      
      def zcash_outputs_hash
        outputs_bin = @out.map{|o|o.to_payload}.join
        OnChain.blake2b(OnChain::bin_to_hex(outputs_bin), ZCASH_OUTPUTS_HASH_PERSONALIZATION)
      end
      
    end
    
  end
  
end
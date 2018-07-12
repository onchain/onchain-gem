module Bitcoin
  module Protocol

    class Tx
      # Used by bitocin cash with a fork_id of zero.
      #
      # Bitcoin Private has a fork id of 42 and Gold 79.
      #
      # Electrum code for Gold. https://github.com/BTCGPU/electrum/blob/master/lib/transaction.py#L849
      #
      # Elecrum code for Bitocin Private https://github.com/BTCPrivate/electrum-btcp/blob/712117fece1a0028c7f5192c0448ab7cc85e9c3c/lib/transaction.py#L764
      #
      def signature_hash_with_a_fork_id(input_idx, 
        script_code, prev_out_value, hash_type, fork_id)
       
        hash_prevouts = Digest::SHA256.digest(Digest::SHA256.digest(
          @in.map{|i| [i.prev_out_hash, i.prev_out_index].pack("a32V")}.join))
          
        hash_sequence = Digest::SHA256.digest(Digest::SHA256.digest(
          @in.map{|i|i.sequence}.join))
          
        outpoint = [@in[input_idx].prev_out_hash, 
          @in[input_idx].prev_out_index].pack("a32V")
          
        amount = [prev_out_value].pack("Q")
        
        nsequence = @in[input_idx].sequence
        
        hash_outputs = Digest::SHA256.digest(Digest::SHA256.digest(
          @out.map{|o|o.to_payload}.join))
        
        hash_type |= fork_id << 8
  
        buf = [ [@ver].pack("V"), hash_prevouts, hash_sequence, outpoint,
                script_code, amount, nsequence, hash_outputs, 
                [@lock_time, hash_type].pack("VV")].join
  
        Digest::SHA256.digest( Digest::SHA256.digest( buf ) )
      end
    end
    
  end
  
end
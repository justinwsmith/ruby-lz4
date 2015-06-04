require 'tempfile'
require 'lz4block'

class LZ4BlockReader
  def initialize input, default_threshold=64
    @input = input
    @default_threshold = default_threshold
  end

  def read_block &lit_callback
    token = @input.readbyte
    bytes_read = 1

    ll = token >> 4
    ml = token % 16 + 4

    if ll == 15
      while true
        byte = @input.readbyte
        bytes_read += 1

        ll += byte
        if byte < 255
          break
        end
      end
    end

    lr = ll
    while lr > 0
      lits = @input.read([lr, 2**16].min)
      if lits
        lit_callback and lit_callback.call(lits)
        lr -= lits.size
      else
        if lr > 0
          raise "Unable to read literals. Remaining: #{lr}"
        end
        break
      end
    end
    bytes_read += ll

    if @input.eof?
      LZ4Block.new(ll, nil, nil, bytes_read)
    else
      mo = @input.readbyte
      mo |= @input.readbyte * 256
      bytes_read +=2

      if ml == 15
        while true
          byte = @input.readbyte
          bytes_read += 1

          ml += byte
          if byte < 255
            break
          end
        end
      end

      LZ4Block.new(ll, ml, mo, bytes_read)
    end
  end
end

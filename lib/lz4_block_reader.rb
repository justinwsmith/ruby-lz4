require 'tempfile'
require 'stringio'

class LZ4BlockReader
  def initialize input, default_threshold=64
    @input = input
    @default_threshold = default_threshold
  end

  def read_block threshold=nil
    token = @input.readbyte
    bytes_read = 1

    ll = token >> 4
    ml = token % 16

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
    if lr > (threshold || @default_threshold)
      literals_dest = Tempfile.new("ruby-lz4", :encoding => 'ascii-8bit')
    else
      literals_dest = StringIO.new()
    end
    while lr > 0
      lits = @input.read([lits_remaining, 2**16].min)
      if lits
        literals_dest.write(lits)
        lr -= lits.length
      else
        if lr > 0
          raise "Unable to read literals. Remaining: #{lits_remaining}"
        end
        break
      end
    end
    literals_dest.flush
    literals_dest.rewind
    bytes_read += ll

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

    LZ4Block.new(ll, literals_dest, ml, mo, bytes_read)
  end
end
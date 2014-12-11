
class LZ4BlockWriter
  attr_reader :bytes_written
  def initialize output, default_threshold=64
    @output = output
    @default_threshold = default_threshold
    @bytes_written = 0
  end

  def write_block lz4block
    ll = lz4block.literals_len
    ml = lz4block.match_len - 4

    if ll >= 15
      token = 15
    else
      token = lz4block.literals_len
    end
    ll -= 15
    token <<= 4

    if ml >= 15
      token |= 15
    else
      token |= ml
    end
    ml -= 15
    @output.putc(token)
    @bytes_written += 1

    while ll >= 0
      if ll >= 255
        @output.putc(255)
        @bytes_written += 1
        ll -= 255
      else
        @output.putc(ll)
        @bytes_written += 1
        break
      end
    end

    lits_remaining = lz4block.literals_len
    lsrc = lz4block.literals_src
    while lits_remaining > 0
      lits = lsrc.read([lits_remaining, 2**16].min)
      if lits
        @output.write(lits)
        lits_remaining -= lits.length
      else
        if lits_remaining > 0
          raise "Unable to read literals. Remaining: #{lits_remaining}"
        end
        break
      end
    end
    @bytes_written += lz4block.literals_len

    # little-endian
    @output.putc(@match_off % 256)
    @output.putc(@match_off >> 8)
    @bytes_written += 2

    while ml >= 0
      if ml >= 255
        @output.putc(255)
        @bytes_written += 1
        ml -= 255
      else
        @output.putc(ml)
        @bytes_written += 1
        break
      end
    end
  end
end
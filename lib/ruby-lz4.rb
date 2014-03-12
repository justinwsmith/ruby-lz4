require "ruby-lz4/version"
require 'stringio'

module LZ4

  @@seven1s = 2**7 -1

  def LZ4.compress(string, high_compression = false)
    LZ4._compress StringIO.new(string, "rb"), (high_compression ? LZ4Compress : LZ4CompressHC)
  end

  def LZ4.compressHC(string)
    return LZ4.compress(string, true)
  end

  def LZ4.uncompress(string)
    return LZ4._uncompress(StringIO.new(string, "rb"), LZ4Uncompress)
  end

  class LZ4Uncompress
    @@states = [:token, :litlen, :lits, :offset, :matchlen]

    def initialize input, output
      @input = input
      @output = output
    end

    def uncompress

      while true
        token = @input.readbyte
        litlen = (token & 0xF0) >> 4
        matchlen = (token & 0x0F)
        if litlen == 15
          begin
            byte = @input.readbyte
            litlen += byte
          end while byte == 255
        end



      end

    end
  end

  class LZ4Compress
    def initialize input, output
      @input = input
      @output = output
    end

    def compress str
      raise "Not implemented"
    end
  end

  class LZ4CompressHC
    def initialize input, output
      @input = input
      @output = output
    end

    def compress str
      raise "Not implemented"
    end
  end



private

  def LZ4._compress input, lz4cls
    output = StringIO.new("", "wb")
    LZ4._encode_header(input.size, output)

    lz4 = lz4cls.new input, output
  end

  def LZ4._uncompress input, lz4cls
    output = StringIO.new("", "wb")
    length = LZ4._decode_header(input)

    lz4 = lz4cls.new input, output
    lz4.uncompress
  end

  def LZ4._encode_header length, output
    result = []
    while true
      byte = length & @@seven1s
      length >>= 7
      if length > 0
        byte |= 128
        output.putc(byte)
      else
        break
      end
    end
    output.putc(byte)
  end

  def LZ4._decode_header input
    result = 0
    iter = 0
    while true
      byte = input.readbyte
      result += (128**iter) * (byte & @@seven1s)
      if (byte & 128) == 0
        return result
      end
      iter += 1
    end
  end

end

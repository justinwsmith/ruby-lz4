require "ruby-lz4/version"
require 'stringio'
require 'cyclicbuffer'

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

    def initialize output
      @buffer = CyclicBuffer.new(2**16)
      @output = output
    end

    # TODO: ridiculously slow
    def uncompress input

      while true
        token = input.readbyte
        litlen = (token & 0xF0) >> 4
        matchlen = (token & 0x0F)
        if litlen == 15
          begin
            byte = input.readbyte
            litlen += byte
          end while byte == 255
        end
        litlen.times do
          byte = input.readbyte
          @buffer.write(byte)
          @output.write(byte.chr("ASCII-8BIT"))
        end

        break if input.eof?

        offset = input.readbyte + (256*input.readbyte)

        if matchlen == 15
          begin
            byte = input.readbyte
            matchlen += byte
          end while byte == 255
        end

        match = @buffer.relative(-offset, matchlen + 4)
        @buffer.write(*match)
        @output.write(match.pack("C*"))

        break if input.eof?
      end
    end
  end

  class LZ4Compress
    def initialize output, buffer_size = 2**12
      @output = output
    end

    def compress input


    end
  end

  class LZ4CompressHC < LZ4Compress
    def initialize output
      super(output, 2**16)
    end
  end

private

  def LZ4._compress input, lz4cls
    output = StringIO.new("", "wb")
    LZ4._encode_header(input.size, output)

    lz4 = lz4cls.new output
    lz4.compress input
    output.string
  end

  def LZ4._uncompress input, lz4cls
    output = StringIO.new("", "wb")
    length = LZ4._decode_header(input)

    lz4 = lz4cls.new output
    lz4.uncompress input
    result = output.string

    if result.length != length
      raise "Mismatched length: Data may be corrupt"
    end
    result
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

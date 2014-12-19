
class RollingChecksumReader
  attr_reader :hash, :max_size, :seed, :pos

  def initialize input, max_size = 4, seed = 31
    @max_size = max_size
    @seed = seed
    @input = input

    @pos = 0
    @checksum = 0
    @window = []
    @max_size.times do
      byte = input.getbyte
      if !byte
        break
      end
      @window << byte
      @checksum = @checksum * @seed + byte
    end
  end

  def read length, &callback
    result = ""
    pos = @pos
    checksums = []
    length.times do
      byte = getbyte do |pos, sum|
        checksums.push(sum)
      end
      if byte
        result << byte
      else
        break
      end
    end
    callback.call(pos, checksums) if callback
    result
  end

  def getbyte &callback
    if @window.length == 0
      return nil
    end

    callback.call(@pos, @checksum)
    @pos += 1
    first = @window.shift
    @checksum -= first * @seed ** (@window.length-1)


    byte = @input.getbyte
    if byte
      @window.push byte
    else
      byte = 0
    end
    @checksum = @checksum * @seed + byte

    first
  end
end
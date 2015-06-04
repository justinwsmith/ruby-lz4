require 'rolling_checksum_byte_processor'

class LZ4FileBuffer

  attr_reader :max_offset

	def initialize io, max_offset = (2**16-1), window_size = 4
		raise "Unable to read from file!" if io.eof?
    @io = io
		@max_offset = max_offset
		
    @window = WindowHash.new window_size
    @lookahead = []

    window_size.times do 
      raise "Unable to read file!" unless load_window() 
    end
	end

	def nextbyte
    hash = @window.hash
    byte = load_window
    return false unless byte

    [byte, hash]
  end

  def load_window
    if @lookahead.length == 0
      return nil unless load_lookahead
    end

    @window.add_byte(@lookahead.shift)
  end

  def load_lookahead
    return nil if @io.eof?
    
    data = @io.read(@max_length).each_byte.to_a

    @lookahead.push *data

    #puts "Lookahead: #{@lookahead[0...10].inspect}"

    data.length
  end

  def getbyte offset
    if offset < @window.window_max
      return @window[offset]
    elsif offset >= (@lookahead.size+@window.window_max)
      while offset >= (@lookahead.size + @window.window_max)
        return nil unless load_lookahead
      end
    end

    @lookahead[offset - @window.max_size]
  end 

  def window_size
    @window.window_max
  end

  def hash_seed
    @window.seed
  end

  def to_s
    str = "<#LZ4FileBuffer:@window="
    str << @window.to_s
    str << ";@lookahead=["
    str << @lookahead[0...5].join(", ")
    str << "]>"
    str
  end
end


class RollingChecksumByteProcessor
  attr_reader :history_max, :window_max, :seed, :pos

  def initialize history_max=2**16, window_max = 4, seed = 31
    @history_max = history_max
    @window_max = window_max
    @seed = seed

    @checksum = 0
    @window = []
    @history = []
  end

  def process byte, &callback
    if @window.length >= @window_max
      first = @window.shift
      if @history.length >= (@history_max - @window_max)
        @history.shift
      end
      @history << @checksum
      @checksum -= first ** (@max_size-1)
    end
    @checksum = @checksum * @seed + byte
  end

  def checksum pos
    if pos > @window.length + @history.length || pos < 1
      raise "Invalid position: #{pos}"
    end
    if pos >= @window_max
      @history[(@history.length + @window.length) - (pos + 1)]
    else
      cs = 0
      @window[(-pos)..(-1)].each do |x|
        cs = cs * @seed + x
      end
      cs
    end
  end

end

class CyclicBuffer
  def initialize size
    @buffer = Array.new(size, 0)
    @cycling == false
    @next = 0
  end

  def write *items
    i = 0
    while true
      remaining = items.length - i
      available = @buffer.length - @next
      if remaining < available
        break
      end
      @buffer[@next, available] = items[i, available]
      i += available
      @cycling = true
      @next = 0
    end
    @buffer[@next, remaining] = items[i, remaining]
    @next += remaining
  end

  def reference pos, length = 1
    size = @cycling ? @buffer.length : @next
    if !(((-size)...(size)) === pos)
      raise "Pos #{pos} -- beyond size of buffer."
    end

    result = []
    idx = (@next + pos) % size
    while true
      remaining = length - result.length
      available = size - idx
      if remaining < available
        break
      end
      result.push *(@buffer[idx, available])
      idx = 0
    end
    result.push *(@buffer[idx, remaining])
  end
end

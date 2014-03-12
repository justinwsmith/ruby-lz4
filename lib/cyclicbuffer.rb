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
    start = (@next + pos) % size
    available = (pos < 0) ? (-pos) : (size - pos)
    finish = (start + available) % size

    if finish <= start
      while true
        remaining = length - result.length
        if remaining > available
          result.push *(@buffer[start...size])
          result.push *(@buffer[0...finish])
        elsif remaining > (@buffer.length - start)
          result.push *(@buffer[start...size])
          result.push *(@buffer[0, remaining - (@buffer.length - start)])
          break
        else
          result.push *(@buffer[start, remaining])
          break
        end
      end
    else
      while true
        remaining = length - result.length
        if remaining > available
          result.push *(@buffer[start, available])
        else
          result.push *(@buffer[start, remaining])
          break
        end
      end
    end
    result
  end
end

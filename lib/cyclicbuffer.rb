class CyclicBuffer

  def initialize size, fill_val = 0
    @buffer = Array.new(size, fill_val)
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

  def last
    return nil if @next == 0 && !@cycling

    (@next - 1) % @buffer.length
  end

  def absolute pos, length = 1

    if pos < 0 || pos >= size || (pos >= @next && !@cycling)
      raise "Pos #{pos} -- invalid absolute position"
    end

    relative(pos - @next, length)
  end

  def size
    @buffer.length
  end

  alias_method :length, :size

  def number
    @cycling ? @buffer.length : @next
  end

  def relative pos, length = 1
    size = number
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


class HashingCyclicBuffer

  attr_reader :factor

  Node = Struct.new(:byte, :next, :prev, :next_mmc)

  def initialize size, minmatch, factor = 33
    @buffer = CyclicBuffer.new(size, nil)
    @recents = CyclicBuffer.new(minmatch, nil)
    @minmatch = minmatch

    @dictionary = Hash.new

    @factor = factor
    @maxfactor = factor ** (hash_len-1)
  end

  def write *bytes
    bytes.each do |byte|
      if @buffer.number == @buffer.size
        old = @buffer.relative(0)
        old.prev.next = old.next
        old.next.prev = old.prev
        old.next = nil
        old.prev = nil
      end

      node = Node.new(byte)

      @recents.write(node)


      (1..(hash_len-1)).each do |i|
        break if i > @buffer.number
        _recompute_hash(-i)
      end
    end
  end

  private

  def _compute_hash pos
    buff = relative(pos, @hash_len)
    node = buff[0]
    node.hash = node.byte
    (1...hash_len).each do |i|
      node.hash *= @factor
      node.hash += buff[i].byte
    end
  end
end

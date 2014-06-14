
class WindowHash
  attr_reader :hash, :max_size, :seed

  def initialize max_size = 4, seed = 31
    @max_size = max_size
    @seed = seed
    @hash = 0
    @window = []
  end

  def add_byte b
    @window.push b
    if @window.length > @max_size
      first = @window.shift
      @hash -= first * @seed ** (@max_size-1)
    end
    @hash = @hash * @seed + @window.last
    first || -1
  end

  def [] index
    raise "Invalid index" unless (0...@max_size) === index
    @window[index]
  end

  def size
    @window.size
  end

  def to_s
    str = "<#WindowHash:["
    str << @window.join(", ")
    str << "];@hash=#{@hash};@max_size=#{@max_size};@seed=#{@seed}>"
    str
  end
end
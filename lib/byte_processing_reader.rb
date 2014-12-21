
class ByteProcessingReader

  def initialize input
    @input = input
    @byte_processors = []
  end

  def add_byte_processor bp
    @byte_processors << bp
  end

  def process_byte byte
    @byte_processors.each do |bp|
      bp.process(byte)
    end
    byte
  end

  def read length
    data = input.read
    data.each_byte do |byte|
      process_byte byte
    end
    data
  end

  def getbyte &callback
    process_byte byte @input.getbyte
  end
end
require 'spec_helper'
require 'lz4-filebuffer'

require 'stringio'

FILE = 'data/lz4-google-code.html'

describe LZ4FileBuffer do

  before do
    @contents = File.read(FILE)
    #puts "Contents: #{@contents[0...10].each_byte.map {|x| x.ord} }"
  end

  describe "#nextbyte" do
    before do
      @buffer = LZ4FileBuffer.new(File.open(FILE))
      #puts "Contents: #{@contents[0...10].each_byte.map {|x| x.ord} }"
    end

    it "should return the next byte and the corresponding hash" do
        
      retval = @buffer.nextbyte
      #puts "retval: #{retval.inspect}"

      expect(retval[0]).to eq(@contents[0].ord)
      hash = (0...(@buffer.window_size)).map {|j| (@buffer.hash_seed ** (@buffer.window_size-j-1)) * @contents[j].ord }.inject(:+)
      expect(retval[1]).to eq(hash)
      #puts "Buffer: #{@buffer}"

      (1...8).each do |i|
        retval = @buffer.nextbyte
        expect(retval[0]).to eq(@contents[i].ord)
        hash = (i...(i+@buffer.window_size)).map {|j| (@buffer.hash_seed ** (@buffer.window_size-(j-i)-1)) * @contents[j].ord }.inject(:+)
        expect(retval[1]).to eq(hash)
        #puts "Buffer: #{@buffer}"
      end
    end
  end

  describe '#getbyte' do
    before do
      @buffer = LZ4FileBuffer.new(File.open(FILE))
      #puts  "Buffer: #{@buffer}"
    end

    context "should return the byte at" do
      32.times do |i|
        it "offset #{i}" do
          expect(@buffer.getbyte(i)).to eq(@contents[i].ord)
        end
      end
    end


    32.times do |i|
      it "should return the byte and the given offset" do
        offset = rand(@contents.length)
        expect(@buffer.getbyte(offset)).to eq(@contents[offset].ord)
      end
    end

=begin
    it "should return the byte and the given offset" do

      iters = rand(32)
      iters.times { @buffer.nextbyte }

      32.times do |i|
        offset = rand(@contests.length - iters)
        expect(@buffer.getbyte(offset)).to eq(@contents[offset + iters].ord)
      end
    end
=end
  end
end

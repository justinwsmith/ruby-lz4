require 'spec_helper'
require 'stringio'
require 'rolling_checksum_reader'

$hashes = []

describe RollingChecksumReader do

  describe 'normal input' do

    before do
      @input = 'abcdefzxy'
      @whash = RollingChecksumReader.new StringIO.new(@input.dup)
    end

    it "getbyte should return a hash for each byte" do
      @input.length.times do |i|
        byte = @whash.getbyte do |pos, hash|
          expect(pos).to eq(i)
          $hashes << hash
        end
        expect(byte).to eq(@input[i].ord)
      end
    end

    it "getbyte should return a hash for each byte" do
      result = @whash.read(@input.length) do |pos, hashes|
        expect(pos).to eq(0)
        expect(hashes).to eq($hashes)
      end
      expect(result).to eq(@input)
    end

=begin
    it "should hash using seed" do
      ary = (2*@whash.max_size).times.map { rand(256) }
      (0...@whash.max_size).each { |i| @whash.add_byte(ary[i]) }


      (0...@whash.max_size).each do |i|
        result = @whash.hash
        hash = (i...(i+@whash.max_size)).map {|j| (@whash.seed ** (@whash.max_size-(j-i)-1)) * ary[j] }.inject(:+)
        expect(result).to eq(hash)
        index = i + @whash.max_size
        @whash.add_byte(ary[index])
      end
    end

    it "should hash using seed" do
      ary = (2*@whash.max_size).times.map { rand(256) }
      (0...@whash.max_size).each { |i| @whash.add_byte(ary[i]) }


      (0...@whash.max_size).each do |i|
        result = @whash.hash
        hash = (i...(i+@whash.max_size)).map {|j| (@whash.seed ** (@whash.max_size-(j-i)-1)) * ary[j] }.inject(:+)
        expect(result).to eq(hash)
        index = i + @whash.max_size
        @whash.add_byte(ary[index])
      end
    end
=end

  end

end

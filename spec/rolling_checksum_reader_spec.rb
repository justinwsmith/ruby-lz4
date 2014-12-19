require 'spec_helper'
require 'stringio'
require 'rolling_checksum_reader'

$normal_hashes = []
$short_hashes = []

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
          $normal_hashes << hash
        end
        expect(byte).to eq(@input[i].ord)
      end
    end

    it "getbyte should return a hash for each byte" do
      result = @whash.read(@input.length) do |pos, hashes|
        expect(pos).to eq(0)
        expect(hashes).to eq($normal_hashes)
      end
      expect(result).to eq(@input)
    end

  end

  describe 'short input' do
    before do
      @input = 'ac'
      @whash = RollingChecksumReader.new StringIO.new(@input.dup)
    end

    it "getbyte should return a hash for each byte" do
      @input.length.times do |i|
        byte = @whash.getbyte do |pos, hash|
          expect(pos).to eq(i)
          $short_hashes << hash
        end
        expect(byte).to eq(@input[i].ord)
      end
    end

    it "getbyte should return a hash for each byte" do
      result = @whash.read(@input.length) do |pos, hashes|
        expect(pos).to eq(0)
        expect(hashes).to eq($short_hashes)
      end
      expect(result).to eq(@input)
    end

  end

end
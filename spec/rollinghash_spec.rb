require 'spec_helper'
require 'rollinghash'


describe WindowHash do

  describe "hash implementation" do
    before do 
      @whash = WindowHash.new
    end
    
    it "should initialliy be zero" do
      expect(@whash.hash).to eq(0)
    end

    it "should use single byte as its value" do
      @whash.add_byte(73)
      expect(@whash.hash).to eq(73)
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


  end

end

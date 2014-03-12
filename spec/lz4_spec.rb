require 'spec_helper'
require 'stringio'
require 'yaml'
YAML::ENGINE.yamler='syck'

describe LZ4 do

  describe "_encode_header" do
    hash = YAML.load(IO.read 'spec/header.yaml')
    hash.each do |key, value|
      it "should encode value in base 128" do
        output = StringIO.new("", "w")
        output.set_encoding("ASCII-8BIT")
        LZ4.send(:_encode_header, key, output)
        result = output.string
        expected = value.pack("C*")

        # There must be a better way than this!?
        # expected = expected.force_encoding("ISO-8859-1").encode("US-ASCII")

        #$stderr << "Result: " << result.each_byte.to_a.to_s << "\n"
        #$stderr << "Result: " << result.encoding << "\n"
        #$stderr << "Expected:   " << expected.each_byte.to_a.to_s << "\n"
        #$stderr << "Expected: " << expected.encoding << "\n"
        #result.each_byte.to_a.should eq(expected.each_byte.to_a)

        result.should eq(expected)
      end
    end
  end


  describe "_decode_header" do
    hash = YAML.load(IO.read 'spec/header.yaml')
    hash.each do |key, value|
      it "should decode value from base 128" do
        LZ4.send(:_decode_header, StringIO.new(value.pack("C*"))).should eq(key)
      end
    end
  end

  describe "uncompress" do
    hash = YAML.load(IO.read 'spec/uncompress.yaml')
    hash.each do |key, value|
      it "should decompress strings" do
        LZ4.uncompress(key) == value
      end
    end
  end

end

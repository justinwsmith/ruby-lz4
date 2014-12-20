require 'rspec'
require 'stringio'
require 'yaml'
require 'lz4_block_reader'

describe 'read blocks' do
  it 'should collect the literals length correctly' do
    test_data = YAML.load( open('spec/uncompress.yaml').read )
    test_data.each do |data, result|
      input = StringIO.new(data)
      reader = LZ4BlockReader.new(input)
      block = reader.read_block
      # attr_reader :literals_len, :literals_src, :match_len, :match_off, :size
      expect(block.size).to eq(result.length + (result.length >= 15 ? 2 : 1))
      expect(block.match_off).to eq(nil)
      expect(block.match_len).to eq(nil)
      expect(block.literals_len).to eq(result.length)
      expect(block.literals_src.read()).to eq(result)
    end
  end
end
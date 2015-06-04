require 'rspec'
require 'stringio'
require 'yaml'
require 'lz4_block_reader'


describe 'LZ4BlockReader' do

  it 'should collect the literals correctly' do
    test_data = YAML.load( open('spec/literals.yaml').read )
    test_data.each do |data, result|
      input = StringIO.new(data)
      reader = LZ4BlockReader.new(input)
      literals_src = StringIO.new("")
      block = reader.read_block { |lits|
        literals_src = StringIO.new(lits)
      }
      # attr_reader :literals_len, :match_len, :match_off, :size
      expect(block.match_off).to eq(nil)
      expect(block.match_len).to eq(nil)
      expect(block.literals_len).to eq(result.length)
      expect(literals_src.read()).to eq(result)
      expect(block.size).to eq(result.length + 1 + (block.literals_len >= 15 ? 1 : 0))
    end
  end
  it 'should collect the blocks correctly' do
    test_data = YAML.load( open('spec/matches.yaml').read )
    test_data.each do |data, result|
      input = StringIO.new(data)
      reader = LZ4BlockReader.new(input)
      literals_src = StringIO.new("")
      block = reader.read_block { |lits|
        literals_src = StringIO.new(lits)
      }
      # attr_reader :literals_len, :literals_src, :match_len, :match_off, :size
      expect(block.match_off).to eq(result[2])
      expect(block.match_len).to eq(result[1])
      expect(block.literals_len).to eq(result[0].length)
      expect(literals_src.read()).to eq(result[0])
      expect(block.size).to eq(result[0].length + 3 + (block.literals_len >= 15 ? 1 : 0) + ((block.match_len||0) >= 15 ? 1 : 0))
    end
  end

end

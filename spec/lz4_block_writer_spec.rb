require 'rspec'
require 'lz4block'
require 'lz4_block_writer'
require 'stringio'

describe 'LZ4BlockWriter' do

  describe 'output' do
    matches = [ [nil, nil], [4, 20], [28, 20] , [19, 356]]
    literals = %w{ cat caterpillar antidisestablishmentarianism }
    literals.each do |literal|
      matches.each do |ml, mo|
        dest = StringIO.new
        dest.set_encoding('ASCII-8BIT')
        writer = LZ4BlockWriter.new(dest)
        writer.write_block(LZ4Block.new(literal.size, ml, mo)) do |lits_remaining|
          raise "#{lits_remaining} != #{literal.length}" if lits_remaining != literal.length
          literal
        end
        writer.flush
        result = dest.string
        puts "Output: #{result.inspect}"


        if literal.length >= 15
          it 'should output long literals' do
            # TODO: Test support for literals longer than 270 bytes
            expect(result[0].ord >> 4).to eq(15)
            expect(result[1].ord).to eq(literal.length - 15)
            expect(result[2, literal.length]).to eq(literal)
          end
        else
          it 'should output short literals' do
            expect(result[0].ord >> 4).to eq(literal.length)
            expect(result[1, literal.length]).to eq(literal)
          end
        end

        if !ml
          it 'should output nil matches' do
            expect(result[-1].ord).to eq(0)
            expect(result[-2].ord).to eq(0)
            expect(result[0].ord % 16).to eq(0)
          end
        elsif ml >= 19
          it 'should output long matches' do
            # TODO: Test support for match length longer than 270 bytes
            expect(result[0].ord % 16).to eq(15)
            expect(result[-1].ord).to eq(ml - 19)
            expect(result[-3].ord + 256*result[-2].ord).to eq(mo)
          end
        else
          it 'should output short matches' do
            expect(result[0].ord % 16).to eq(ml-4)
            expect(result[-2].ord + 256*result[-1].ord).to eq(mo)
          end
        end
      end
    end
  end

end

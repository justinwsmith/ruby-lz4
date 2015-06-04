
class LZ4Block

	attr_reader :literals_len, :match_len, :match_off, :size

	def initialize literals_len, match_len, match_off, size = nil
		if literals_len < 0
			raise "Invalid LZ4 block: *ll*=#{literals_len}, ml=#{match_len}, mo=#{match_off}"
		end
		if match_off && (match_len < 4 || match_off < 1 || match_off >= 2**16-1)
			raise "Invalid LZ4 block: ll=#{literals_len}, ml=#{match_len}, *mo*=#{match_off}"
		end
		if (!match_off) ^ (!match_len)
			# It should always be the case that either both values are specified or neither
			raise "Invalid LZ4 block: ll=#{literals_len}, *ml*=#{match_len}, mo=#{match_off}"
		end

		@literals_len = literals_len
		@match_len = match_len
		@match_off = match_off
		@size = size
	end

end

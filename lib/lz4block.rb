
class LZ4Block

	attr_reader :literals_len, :literals_src, :match_len, :match_off, :size

	def initialize literals_len, literals_src, match_len, match_off, size=nil
		if literals_len < 0 || (match_off && (match_len < 4 || match_off < 1 || match_off >= 2**16-1)) || (match_off ^ match_len)
			raise "Invalid LZ4 block: #{literals_len}, #{match_len}, #{match_off}"
		end
		@literals_len = literals_len
		@literals_src = literals_src
		@match_len = match_len
		@match_off = match_off
		@size = size
		ObjectSpace.define_finalizer(self, proc { self.close })
	end

	def close
		if @literals_src.is_a? Tempfile
			@literals_src.close(true)
		else
			@literals_src.close
		end
	end

end

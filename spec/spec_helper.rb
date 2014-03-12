require 'bundler/setup'

Bundler.setup


require 'ruby-lz4'

def generate_random_bytes(len)
  result = []
  len.times do |t|
    result << rand(256)
  end
  return result.pack("C*")
end

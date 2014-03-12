require "descriptive_statistics"

def hash(ary, x = 33)
  ((ary[0] * x + ary[1]) * x + ary[2]) * x + ary[3]
end

primes = (24..40)

primes.each  do |x|
  hist = Hash.new(0)
  hs = 2**16
  200000.times do
    hist[ hash(4.times.map { rand(32..126) }, x) % hs] += 1
  end
  vals = []
  (0...hs).step(256) do |i|
    total = 0
    (0...256).each do |j|
      total += hist[(i+j) % hs]
    end
    vals << total
  end

  #puts "Avg: #{vals.mean}"
  #puts "Median: #{vals.median}"
  puts "X: #{x} std-dev: #{vals.standard_deviation}"
end

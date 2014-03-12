require 'spec_helper'
require 'cyclicbuffer'

[
  CyclicBuffer,
  #HashingCyclicBuffer
].each do |cls|

  describe cls do

    it "should allow relative to previous written values" do
      cb = cls.new 4
      cb.write 1, 2, 3
      cb.relative(-2, 2).should eq([2, 3])
      cb.relative(-3, 2).should eq([1, 2])
      cb.relative(0, 2).should eq([1, 2])
    end

    it "should allow relative to previous written values" do
      cb = cls.new 4
      cb.write *[4, 5, 6, 7]
      cb.relative(-2, 2).should eq([6, 7])
      cb.relative(-4, 2).should eq([4, 5])
      cb.write 8
      cb.relative(-2, 2).should eq([7, 8])
      cb.relative(-4, 2).should eq([5, 6])
      cb.write 9
      cb.relative(-2, 2).should eq([8, 9])
      cb.relative(-4, 2).should eq([6, 7])
    end

    it "should allow writing more values than itssize" do
      cb = cls.new 4
      cb.write *[4, 5, 6, 7, 8, 9]
      cb.relative(-2, 2).should eq([8, 9])
      cb.relative(-4, 2).should eq([6, 7])
    end

    it "should repeat when length excedes size" do
      cb = cls.new 2
      cb.write 1, 2
      cb.relative(-2, 5).should eq([1,2,1,2,1])
      cb.write 3
      cb.relative(-2, 5).should eq([2,3,2,3,2])
    end

    it "should repeat when length excedes size" do
      cb = cls.new 4
      cb.write 1
      cb.relative(-1, 5).should eq([1,1,1,1,1])
      cb.write 2
      cb.relative(-1, 5).should eq([2,2,2,2,2])
    end

    it "should repeat when length excedes size" do
      cb = cls.new 4
      cb.write *[4, 5, 6, 7, 8, 9]
      cb.relative(-2, 5).should eq([8,9,8,9,8])
      cb.write 3
      cb.relative(-3, 4).should eq([8,9,3,8])
      cb.relative(1, 5).should eq([8,9,3,8,9])
    end

    it "should repeat when length excedes size" do
      cb = cls.new 4
      cb.write *[4, 5, 6, 7, 8, 9]
      cb.relative(-2, 5).should eq([8,9,8,9,8])
      cb.write 3
      cb.relative(-3, 4).should eq([8,9,3,8])
      cb.relative(1, 5).should eq([8,9,3,8,9])
    end

  end
end
# Assume this is how it should be computed
def myhash(ary, factor)
  hash = 0
  (0...(ary.length)).each do |i|
    hash *= factor
    hash += ary[i]
  end
  hash
end

=begin
describe HashingCyclicBuffer do


  it "should compute a hash" do
    hcb = HashingCyclicBuffer.new 4
    ary = [120]
    hcb.write *ary
    hcb.hash.should eq(myhash(ary * 4, hcb.factor))
  end

  it "should compute a hash" do
    hcb = HashingCyclicBuffer.new 4
    ary = [120, 234]
    hcb.write *ary
    hcb.hash.should eq(myhash(ary * 2, hcb.factor))
  end

  it "should compute a hash" do
    hcb = HashingCyclicBuffer.new 4
    ary = [5, 6, 7, 8, 9]
    hcb.write *ary
    hcb.hash.should eq(myhash(ary[-4..-1], hcb.factor))
  end
end
=end

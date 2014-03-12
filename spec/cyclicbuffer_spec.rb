require 'spec_helper'
require 'cyclicbuffer'

describe CyclicBuffer do

  it "should allow reference to previous written values" do
    cb = CyclicBuffer.new 4
    cb.write 1, 2, 3
    cb.reference(-2, 2).should eq([2, 3])
    cb.reference(-3, 2).should eq([1, 2])
    cb.reference(0, 2).should eq([1, 2])
  end

  it "should allow reference to previous written values" do
    cb = CyclicBuffer.new 4
    cb.write *[4, 5, 6, 7]
    cb.reference(-2, 2).should eq([6, 7])
    cb.reference(-4, 2).should eq([4, 5])
    cb.write 8
    cb.reference(-2, 2).should eq([7, 8])
    cb.reference(-4, 2).should eq([5, 6])
    cb.write 9
    cb.reference(-2, 2).should eq([8, 9])
    cb.reference(-4, 2).should eq([6, 7])
  end

  it "should allow writing more values than itssize" do
    cb = CyclicBuffer.new 4
    cb.write *[4, 5, 6, 7, 8, 9]
    cb.reference(-2, 2).should eq([8, 9])
    cb.reference(-4, 2).should eq([6, 7])
  end

  it "should repeat when length excedes size" do
    cb = CyclicBuffer.new 2
    cb.write 1, 2
    cb.reference(-2, 5).should eq([1,2,1,2,1])
    cb.write 3
    cb.reference(-2, 5).should eq([2,3,2,3,2])
  end

  it "should repeat when length excedes size" do
    cb = CyclicBuffer.new 4
    cb.write 1
    cb.reference(-1, 5).should eq([1,1,1,1,1])
  end

end

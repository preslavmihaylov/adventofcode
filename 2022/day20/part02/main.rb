#!/usr/env/bin ruby

class MyNumber
  attr_reader :v

  def initialize(v)
    @v = v
  end

  def inspect
    "#{v}"
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename).map { |l| MyNumber.new(l.to_i * 811_589_153) }
end

def move(nums)
  moved = nums.dup
  for i in 1..10
    nums.each_index do |idx|
      num = nums[idx]
      start = moved.index(num)
      i = start + num.v
      nexti = i % (moved.length - 1)
      nexti -= 1 if nexti.zero?

      moved.delete_at(moved.index(num))
      moved.insert(nexti, num)
    end
  end

  moved.map { |n| n.v }
end

if __FILE__ == $0
  nums = read_input
  moved = move(nums)
  i = moved.find_index(0)
  puts(moved[(i + 1000) % moved.length] + moved[(i + 2000) % moved.length] + moved[(i + 3000) % moved.length])
end

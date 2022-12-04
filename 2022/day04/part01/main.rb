#!/usr/bin/env ruby

class Range
  def initialize(lower, upper)
    @lower = lower
    @upper = upper
  end

  def self.from_str(str_range)
    Range.new(*str_range.split(/-/, -1).map { |str_num| str_num.to_i })
  end

  attr_reader :lower, :upper
end

def read_input(filename = '../input.txt')
  file = File.open(filename)

  lines = []
  file.each_line do |line|
    lines.append(line)
  end

  lines
end

def is_subset(range1, range2)
  range2.lower >= range1.lower and range2.upper <= range1.upper
end

if __FILE__ == $0
  lines = read_input

  pairs_contained = 0
  lines.each do |line|
    ranges = line.strip.split(/,/, -1).map { |str_range| Range.from_str(str_range) }
    pairs_contained += 1 if is_subset(ranges[0], ranges[1]) or is_subset(ranges[1], ranges[0])
  end

  puts pairs_contained
end

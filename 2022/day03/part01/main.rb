#!/usr/bin/env ruby

def read_input(filename = '../input.txt')
  file = File.open(filename)

  lines = []
  file.each_line do |line|
    lines.append(line)
  end

  lines
end

def priority_of(item)
  val = item.downcase[0].ord - 'a'.ord + 1
  val += 26 if item.upcase == item
  val
end

if __FILE__ == $0
  lines = read_input

  prio_sums = 0
  lines.each do |line|
    left = line[0, line.length / 2]
    right = line[line.length / 2, line.length]

    dup_item = left.scan(/\w/).select { |c| right.include?(c) }[0]
    prio_sums += priority_of(dup_item)
  end

  puts prio_sums
end

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
  lines.each_slice(3) do |group|
    badge = (group[0].chars & group[1].chars & group[2].chars)[0]
    prio_sums += priority_of(badge)
  end

  puts prio_sums
end

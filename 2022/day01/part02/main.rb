#!/bin/usr/env ruby

def read_input(filename = "input.txt")
  calories_per_elf = []
  calories_per_elf.append([])

  data = File.open(filename).read
  data.lines.each do |line|
    if line.strip.empty?
      calories_per_elf.append([])
      next
    end

    calories_per_elf.last.append(line.to_i)
  end

  return calories_per_elf
end

if __FILE__ == $0
  calories_per_elf = read_input()
  max_calories = calories_per_elf.sort_by{ |calories| calories.sum }.last(3)
  puts max_calories.sum{|calories| calories.sum}
end

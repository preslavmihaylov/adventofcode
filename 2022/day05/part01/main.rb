#!/usr/bin/env ruby

class Command
  attr_reader :to_move, :src, :dest

  def initialize(to_move, src, dest)
    @to_move = to_move
    @src = src
    @dest = dest
  end
end

def stack_of(line, last_i, crate)
  line.index(crate, last_i + 1) / 4 + 1
end

def deep_copy(arr)
  Marshal.load(Marshal.dump(arr))
end

def read_stacks(file)
  r_stacks = []
  while true
    line = file.gets
    break if line.strip == ''

    crates = line.split.map { |crate| crate[1, crate.length - 2] }

    last_i = -1
    crates.each do |crate|
      # this is the stack indices line
      break if crate.nil?

      stackno = stack_of(line, last_i, crate)
      last_i = line.index(crate, last_i + 1) + 1

      r_stacks[stackno] = [] if r_stacks[stackno].nil?
      r_stacks[stackno].append(crate)
    end
  end

  r_stacks.map { |stack| stack.nil? ? [] : stack.reverse }
end

def read_commands(file)
  file.map do |line|
    tokens = line.split

    Command.new(tokens[1].to_i, tokens[3].to_i, tokens[5].to_i)
  end
end

def read_input(filename = '../input.txt')
  f = File.open(filename)

  [read_stacks(f), read_commands(f)]
end

def exec_commands(stacks, commands)
  stacks = deep_copy(stacks)
  commands.each do |cmd|
    cmd.to_move.times do
      src = stacks[cmd.src]
      dest = stacks[cmd.dest]

      dest.append(src[-1])
      src.pop
    end
  end

  stacks
end

if __FILE__ == $0
  stacks, commands = read_input
  stacks = exec_commands(stacks, commands)

  print stacks.map { |stack| stack[-1] }.join(''), "\n"
end

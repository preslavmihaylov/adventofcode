#!/usr/bin/env ruby

class Instruction
  attr_reader :cmd, :args

  def initialize(cmd, args)
    @cmd = cmd
    @args = args
  end

  def value
    return args[0] if cmd == 'addx'

    0
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename)
      .map { |line| line.strip.split }
      .map { |tokens| Instruction.new(tokens[0], tokens[1..tokens.length - 1].map { |arg| arg.to_i }) }
end

def cycles_for_instr(instruction)
  case instruction.cmd
  when 'noop'
    1
  when 'addx'
    2
  else
    raise ArgumentError, "invalid instruction #{instruction.cmd}"
  end
end

def read_xreg_at_cycle(instructions, cycleno)
  instr_idx = 0
  instr_cycle = cycles_for_instr(instructions[instr_idx])

  xreg = 1
  for i in 1..cycleno
    if instr_cycle > 0
      instr_cycle -= 1
      next
    end

    xreg += instructions[instr_idx].value
    instr_idx += 1
    instr_cycle = cycles_for_instr(instructions[instr_idx]) - 1
  end

  xreg
end

if __FILE__ == $0
  instructions = read_input

  xreg = 0
  for cycle in [20, 60, 100, 140, 180, 220]
    xreg += cycle * read_xreg_at_cycle(instructions, cycle)
  end

  puts xreg
end

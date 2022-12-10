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

def render_screen(instructions)
  instr_idx = 0
  instr_cycle = cycles_for_instr(instructions[instr_idx]) - 1

  xreg = 1
  for i in 0..239
    print "\n" if i % 40 == 0 and i != 0
    if ((i % 40) - xreg).abs <= 1
      print '#'
    else
      print '.'
    end

    if instr_cycle > 0
      instr_cycle -= 1
      next
    end

    xreg += instructions[instr_idx].value
    instr_idx += 1
    instr_cycle = cycles_for_instr(instructions[instr_idx]) - 1 if instr_idx < instructions.length
  end

  print "\n"
end

if __FILE__ == $0
  instructions = read_input
  render_screen(instructions)
end

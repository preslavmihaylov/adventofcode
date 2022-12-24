#!/usr/env/bin ruby
# Make sure to run this first:
# export RUBY_THREAD_VM_STACK_SIZE=50000000000

class Operation
  def eval
    raise NotImplementedError, 'method not implemented'
  end
end

class ScalarOperation < Operation
  def initialize(num)
    @num = num
  end

  def eval(_monkeys)
    @num
  end
end

class BiOperation < Operation
  def initialize(operator, operand1, operand2)
    @operator = operator
    @operands = [operand1, operand2]
  end

  def eval(monkeys)
    op1 = calc(monkeys, @operands[0])
    op2 = calc(monkeys, @operands[1])
    apply(@operator, op1, op2)
  end

  private

  def calc(monkeys, operand)
    return ScalarOperation.new(operand.to_i).eval if operand =~ /[0-9]+/

    monkeys[operand].eval(monkeys)
  end

  def apply(operator, num1, num2)
    case operator
    when '*'
      num1 * num2
    when '/'
      num1 / num2
    when '+'
      num1 + num2
    when '-'
      num1 - num2
    else
      raise ArgumentError, 'invalid operator'
    end
  end
end

def to_operation(input)
  return ScalarOperation.new(input.strip.to_i) unless input =~ %r{[a-zA-Z0-9]+ [*+-/] [a-zA-Z0-9]+}

  tokens = input.split(/ /)
  BiOperation.new(tokens[1], tokens[0], tokens[2])
end

def read_input(filename = '../input.txt')
  result = {}
  File.readlines(filename).map do |line|
    tokens = line.strip.split(/: /)
    monkey = tokens[0]
    operation = to_operation(tokens[1])
    result[monkey] = operation
  end

  result
end

if __FILE__ == $0
  monkeys = read_input
  puts monkeys['root'].eval(monkeys)
end

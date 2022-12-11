#!/usr/bin/env ruby

require './types'

$divisibleByProduct = 1

def read_input(filename = '../input.txt')
  File.read(filename)
      .split(/\n\n/)
      .map do |str|
        lines = str.split("\n")
        id = lines[0][/Monkey (\d+):/, 1]
        items = lines[1][/Starting items: (.*)/, 1].split(/, /).map { |item| item.to_i }
        operation = lines[2].strip[/Operation: new = (.*)/, 1]
        divisibleBy = lines[3].strip[/Test: divisible by (\d+)/, 1].to_i
        nextMonkeyIfTrue = lines[4].strip[/If true: throw to monkey (\d+)/, 1].to_i
        nextMonkeyIfFalse = lines[5].strip[/If false: throw to monkey (\d+)/, 1].to_i

        $divisibleByProduct *= divisibleBy
        next Monkey.new(id, items, operation, divisibleBy, nextMonkeyIfTrue, nextMonkeyIfFalse)
      end
end

def exec_round(monkeys, idx)
  monkey = monkeys[idx]
  monkey.items.each_index do |i|
    monkey.items_inspected += 1
    monkey.items[i] = monkey.exec_operation(monkey.items[i]) % $divisibleByProduct
    if monkey.items[i] % monkey.divisibleBy == 0
      monkeys[monkey.nextMonkeyIfTrue].items << monkey.items[i]
    else
      monkeys[monkey.nextMonkeyIfFalse].items << monkey.items[i]
    end
  end

  monkeys[idx].items = []
end

def simulate_rounds(monkeys, roundsno)
  for round in 1..roundsno
    monkeys.each_index { |i| exec_round(monkeys, i) }
  end
end

if __FILE__ == $0
  monkeys = read_input
  simulate_rounds(monkeys, 10_000)

  active_monkeys = monkeys.sort_by { |monkey| -monkey.items_inspected }.take(2)
  puts active_monkeys[0].items_inspected * active_monkeys[1].items_inspected
end

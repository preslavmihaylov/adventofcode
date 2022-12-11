#!/usr/bin/env ruby

class Monkey
  attr_reader :id, :operation, :divisibleBy, :nextMonkeyIfTrue, :nextMonkeyIfFalse
  attr_accessor :items, :items_inspected

  def initialize(id, items, operation, divisibleBy, nextMonkeyIfTrue, nextMonkeyIfFalse)
    @id = id
    @items = items
    @operation = operation
    @divisibleBy = divisibleBy
    @nextMonkeyIfTrue = nextMonkeyIfTrue
    @nextMonkeyIfFalse = nextMonkeyIfFalse
    @items_inspected = 0
  end

  def exec_operation(old)
    old = old
    eval(@operation)
  end
end

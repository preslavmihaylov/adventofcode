#!/usr/bin/env ruby

class Movement
  attr_reader :direction, :times

  def initialize(direction, times)
    @direction = direction
    @times = times
  end
end

class Point
  attr_reader :row, :col

  def initialize(row, col)
    @row = row
    @col = col
  end

  def to_s
    "\{#{row}, #{col}\}"
  end
end

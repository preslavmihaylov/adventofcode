#!/usr/env/bin ruby

class Point
  attr_reader :row, :col

  def initialize(row, col)
    @row = row
    @col = col
  end

  def to_s
    "(#{row}, #{col})"
  end
end

class SensorIndication
  attr_reader :sensor, :beacon

  def initialize(sensor, beacon)
    @sensor = sensor
    @beacon = beacon
  end

  def to_s
    "{sensor=#{sensor}, beacon=#{beacon})"
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename).map do |line|
    tokens = line.strip.split(/: /)
    sensor_col = tokens[0][/Sensor at x=(-?\d+)/, 1].to_i
    sensor_row = tokens[0][/Sensor at x=(-?\d+), y=(-?\d+)/, 2].to_i
    beacon_col = tokens[1][/closest beacon is at x=(-?\d+)/, 1].to_i
    beacon_row = tokens[1][/closest beacon is at x=(-?\d+), y=(-?\d+)/, 2].to_i

    next SensorIndication.new(Point.new(sensor_row, sensor_col), Point.new(beacon_row, beacon_col))
  end
end

# This is a mathematical equation.
#
# given: dist=|s.row-b.row|+|s.col-b.col|
# dist >= |s.row-t_row|+|s.row-t_col|
# dist - |s.row-t_row| >= |s.col-t_col|
#
# case 1:
# dist - |s.row-t_row| >= s.col-t_col
# dist - |s.row-t_row| - s.col >= -t_col
# t_col >= |s.row-t_row| + s.col - dist
#
# case 2:
# dist - |s.row-t_row| >= -(s.col-t_col)
# dist - |s.row-t_row| >= -s.col + t_col
# t_col <= dist - |s.row-t_row| + s.col
def covered_cols_at(indications, t_row)
  covered_cols = []
  indications.each do |indication|
    s = indication.sensor
    b = indication.beacon
    dist = (s.row - b.row).abs + (s.col - b.col).abs
    start_range = (s.row - t_row).abs + s.col - dist
    end_range = dist - (s.row - t_row).abs + s.col
    for t_col in start_range..end_range do
      covered_cols.push(t_col) unless b.row == t_row and b.col == t_col
    end
  end

  covered_cols.uniq.length
end

if __FILE__ == $0
  indications = read_input
  print covered_cols_at(indications, 2_000_000), "\n"
end

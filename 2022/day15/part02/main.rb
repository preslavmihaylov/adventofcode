#!/usr/env/bin ruby

$MIN_RANGE = 0
$MAX_RANGE = 4_000_000

class Point
  attr_reader :row, :col

  def initialize(row, col)
    @row = row
    @col = col
  end
end

class SensorIndication
  attr_reader :sensor, :beacon

  def initialize(sensor, beacon)
    @sensor = sensor
    @beacon = beacon
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
def calc_covered_cols_for(indication, t_row)
  s = indication.sensor
  b = indication.beacon
  dist = (s.row - b.row).abs + (s.col - b.col).abs
  start_range = (s.row - t_row).abs + s.col - dist
  end_range = dist - (s.row - t_row).abs + s.col

  [start_range, end_range]
end

def overlap?(i1, i2)
  (i1[0] <= i2[0] and i1[1] >= i2[0]) || (i1[0] <= i2[1] and i1[1] >= i2[1])
end

def normalize(intervals)
  intervals = intervals.sort_by { |i| i[0] }
  r = [intervals[0]]
  for i in 1..intervals.length - 1
    acc = r.last
    given = intervals[i]

    if overlap?(acc, given)
      r.last[0] = [acc[0], given[0]].min
      r.last[1] = [acc[1], given[1]].max
    else
      r.push(given)
    end
  end

  r
end

def distress_beacon_from(intervals)
  if intervals.length == 1
    return 0 if intervals.first[0] > 0
    return $MAX_RANGE if intervals.last[1] < $MAX_RANGE
  elsif intervals.length == 2
    return intervals.first[1] + 1
  else
    raise 'invariant violated - more than one distress beacon found!'
  end

  nil
end

def find_distress_beacon(indications)
  for row in $MIN_RANGE..$MAX_RANGE
    print "processing row #{row}...\n"
    intervals = []
    indications.each do |indication|
      start_range, end_range = calc_covered_cols_for(indication, row)
      next if start_range > end_range

      intervals.push([start_range, end_range])
      intervals = normalize(intervals)
    end

    beacon_col = distress_beacon_from(intervals)
    return Point.new(row, beacon_col) unless beacon_col.nil?
  end

  raise 'invariant violated - distress beacon not found'
end

if __FILE__ == $0
  indications = read_input
  beacon = find_distress_beacon(indications)
  puts beacon.col * 4_000_000 + beacon.row
end

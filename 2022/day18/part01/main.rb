#!/usr/env/bin ruby

require 'set'

class Cube
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end

  def inspect
    "(#{x},#{y},#{z})"
  end

  def eql?(other)
    x == other.x and y == other.y and z == other.z
  end

  def hash
    [@x, @y, @z].hash
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename).map do |line|
    tokens = line.strip.split(/,/)
    Cube.new(tokens[0].to_i, tokens[1].to_i, tokens[2].to_i)
  end
end

def count_visible_sides(cubes, cube)
  cnt = 0
  cnt += 1 unless cubes.include?(Cube.new(cube.x + 1, cube.y, cube.z))
  cnt += 1 unless cubes.include?(Cube.new(cube.x - 1, cube.y, cube.z))
  cnt += 1 unless cubes.include?(Cube.new(cube.x, cube.y + 1, cube.z))
  cnt += 1 unless cubes.include?(Cube.new(cube.x, cube.y - 1, cube.z))
  cnt += 1 unless cubes.include?(Cube.new(cube.x, cube.y, cube.z + 1))
  cnt += 1 unless cubes.include?(Cube.new(cube.x, cube.y, cube.z - 1))

  cnt
end

if __FILE__ == $0
  cubes = Set.new(read_input)

  sum = 0
  cubes.each do |cube|
    sum += count_visible_sides(cubes, cube)
  end

  puts sum
end

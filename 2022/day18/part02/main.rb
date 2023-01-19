#!/usr/env/bin ruby

require 'set'

$MAX_TRAPPED_DEPTH = 5000

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

def is_trapped(cubes, cube, visited, depth)
  return true if cubes.include?(cube) or visited[cube]
  return false if depth > $MAX_TRAPPED_DEPTH

  visited[cube] = true
  return false unless is_trapped(cubes, Cube.new(cube.x + 1, cube.y, cube.z), visited, depth + 1)
  return false unless is_trapped(cubes, Cube.new(cube.x - 1, cube.y, cube.z), visited, depth + 1)
  return false unless is_trapped(cubes, Cube.new(cube.x, cube.y + 1, cube.z), visited, depth + 1)
  return false unless is_trapped(cubes, Cube.new(cube.x, cube.y - 1, cube.z), visited, depth + 1)
  return false unless is_trapped(cubes, Cube.new(cube.x, cube.y, cube.z + 1), visited, depth + 1)
  return false unless is_trapped(cubes, Cube.new(cube.x, cube.y, cube.z - 1), visited, depth + 1)

  true
end

def count_visible_sides(cubes, cube)
  cnt = 0
  cnt += 1 unless is_trapped(cubes, Cube.new(cube.x + 1, cube.y, cube.z), {}, 0)
  cnt += 1 unless is_trapped(cubes, Cube.new(cube.x - 1, cube.y, cube.z), {}, 0)
  cnt += 1 unless is_trapped(cubes, Cube.new(cube.x, cube.y + 1, cube.z), {}, 0)
  cnt += 1 unless is_trapped(cubes, Cube.new(cube.x, cube.y - 1, cube.z), {}, 0)
  cnt += 1 unless is_trapped(cubes, Cube.new(cube.x, cube.y, cube.z + 1), {}, 0)
  cnt += 1 unless is_trapped(cubes, Cube.new(cube.x, cube.y, cube.z - 1), {}, 0)

  cnt
end

if __FILE__ == $0
  # cubes = Set.new(read_input('../input-example.txt'))
  cubes = Set.new(read_input)

  sum = 0
  cubes.each do |cube|
    sum += count_visible_sides(cubes, cube)
  end

  puts sum
end

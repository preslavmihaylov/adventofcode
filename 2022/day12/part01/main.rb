#!/usr/bin/env ruby

$START = 'S'.ord
$END = 'E'.ord

class PathSegment
  attr_reader :row, :col, :distance, :prev_elevation

  def initialize(row, col, distance, prev_elevation)
    @row = row
    @col = col
    @distance = distance
    @prev_elevation = prev_elevation
  end

  def to_s
    "(row=#{row}, col=#{col}, distance=#{distance})"
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename).map { |line| line.strip.split(//).map { |c| c.ord } }
end

def find_start(grid)
  grid.each_index do |row|
    grid[row].each_index do |col|
      return row, col if grid[row][col] == $START
    end
  end

  raise ArgumentError, 'invalid grid - start not found'
end

def elevation_of(cell)
  return 'a'.ord if cell == $START
  return 'z'.ord if cell == $END

  cell.ord
end

def is_valid_route(grid, visited, p)
  return false unless p.row >= 0 && p.row < grid.length && p.col >= 0 && p.col < grid[p.row].length
  return false if visited[p.row][p.col]
  return false if elevation_of(grid[p.row][p.col]) - p.prev_elevation > 1

  true
end

def fastest_route_to_end(grid, start_row, start_col)
  visited = []
  grid.each_index do |row|
    visited.push([])
    grid[row].each do
      visited.last.push(false)
    end
  end

  queue = [PathSegment.new(start_row, start_col, 0, elevation_of(grid[start_row][start_col]))]
  while queue.length > 0
    p = queue.pop
    next unless is_valid_route(grid, visited, p)
    return p.distance if grid[p.row][p.col] == $END

    elevation = elevation_of(grid[p.row][p.col])
    visited[p.row][p.col] = true
    queue.unshift(PathSegment.new(p.row - 1, p.col, p.distance + 1, elevation))
    queue.unshift(PathSegment.new(p.row, p.col + 1, p.distance + 1, elevation))
    queue.unshift(PathSegment.new(p.row + 1, p.col, p.distance + 1, elevation))
    queue.unshift(PathSegment.new(p.row, p.col - 1, p.distance + 1, elevation))
  end

  -1
end

if __FILE__ == $0
  grid = read_input
  row, col = find_start(grid)

  fastest_route = fastest_route_to_end(grid, row, col)
  puts fastest_route
end

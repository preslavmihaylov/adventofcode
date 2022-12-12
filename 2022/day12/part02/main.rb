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

def find_starts(grid)
  rows = []
  cols = []
  grid.each_index do |row|
    grid[row].each_index do |col|
      if grid[row][col] == $START or grid[row][col] == 'a'.ord
        rows.push(row)
        cols.push(col)
      end
    end
  end

  [rows, cols]
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

  100_000
end

if __FILE__ == $0
  grid = read_input
  rows, cols = find_starts(grid)

  min_path = 100_000
  rows.each_index do |i|
    min_path = [min_path, fastest_route_to_end(grid, rows[i], cols[i])].min
  end

  puts min_path
end

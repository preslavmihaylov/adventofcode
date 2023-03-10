#!/usr/env/bin ruby
require 'set'
require 'algorithms'

# prerequisites: gem install kanwei-algorithms
# solution runs in ~150s (2.5m) on my machine
class Blizzard
  attr_reader :row, :col, :direction

  def initialize(row, col, direction)
    @row = row
    @col = col
    @direction = direction
  end

  def move(grid)
    if @direction == '^'
      @row -= 1
      @col = @col
    elsif @direction == '>'
      @row = @row
      @col += 1
    elsif @direction == '<'
      @row = @row
      @col -= 1
    elsif @direction == 'v'
      @row += 1
      @col = @col
    end

    if @row >= grid.length - 1
      @row = 1
    elsif @row <= 0
      @row = grid.length - 2
    elsif @col >= grid[@row].length - 1
      @col = 1
    elsif @col <= 0
      @col = grid[@row].length - 2
    end
  end

  def to_s
    "(#{@row}, #{@col}, #{@direction})"
  end
end

def tokey(row, col)
  "#{row}:#{col}"
end

def fromkey(key)
  tokens = key.split(/:/)
  [tokens[0].to_i, tokens[1].to_i]
end

def read_input(filename = '../input.txt')
  File.read(filename).split(/\n/).map { |row| row.chars }
end

def extract_blizzards(matrix)
  blizzards = []
  matrix.each_index do |row|
    matrix[row].each_index do |col|
      c = matrix[row][col]
      blizzards << Blizzard.new(row, col, c) if c =~ /[v\^<>]/
    end
  end

  blizzards
end

def canmove(grid, blizzards, row, col)
  row >= 0 and
    row < grid.length and
    col >= 1 and
    col < grid[row].length - 1 and
    grid[row][col] != '#' and
    !blizzards.any? { |b| b.row == row and b.col == col }
end

def encode(row, col, round)
  "#{tokey(row, col)}_#{round}"
end

def decode(key)
  encoded_pos = key.split(/_/)[0]
  round = key.split(/_/)[1].to_i

  row, col = fromkey(encoded_pos)
  [row, col, round]
end

def build_blizzard_matrix(grid, blizzards)
  matrix = []
  blizzards.each do |blizzard|
    srow = blizzard.row
    scol = blizzard.col

    blizzard.move(grid)
    positions = []
    while srow != blizzard.row or scol != blizzard.col
      positions << Blizzard.new(blizzard.row, blizzard.col, blizzard.direction)
      blizzard.move(grid)
    end

    positions << Blizzard.new(srow, scol, blizzard.direction)
    matrix << positions
  end

  matrix
end

def distance(srow, scol, erow, ecol)
  Math.sqrt((srow - erow)**2 + (scol - ecol)**2)
end

def getout(grid, rounds, startrow, startcol, endrow, endcol)
  blizzard_matrix = build_blizzard_matrix(grid, extract_blizzards(grid))

  seen = Set.new
  queue = Containers::PriorityQueue.new
  queue.push(encode(startrow, startcol, rounds), 0)
  while queue.length > 0
    key = queue.pop
    row, col, round = decode(key)

    return round if row == endrow and col == endcol
    next if seen.include?(key)

    seen << key

    # print round, "\n"
    blizzards = blizzard_matrix.map { |row| row[round % row.length] }
    if canmove(grid, blizzards, row, col + 1) # right
      queue.push(encode(row, col + 1, round + 1), -(distance(row, col + 1, endrow, endcol) + round))
    end

    if canmove(grid, blizzards, row + 1, col) # down
      queue.push(encode(row + 1, col, round + 1), -(distance(row + 1, col, endrow, endcol) + round))
    end

    if canmove(grid, blizzards, row, col - 1) # left
      queue.push(encode(row, col - 1, round + 1), -(distance(row, col - 1, endrow, endcol) + round))
    end

    if canmove(grid, blizzards, row, col) # wait
      queue.push(encode(row, col, round + 1), -(distance(row, col, endrow, endcol) + round))
    end

    if canmove(grid, blizzards, row - 1, col) # up
      queue.push(encode(row - 1, col, round + 1), -(distance(row - 1, col, endrow, endcol) + round))
    end
  end

  -1
end

if __FILE__ == $0
  # grid = read_input('../input-example.txt')
  grid = read_input
  rounds = getout(grid, 0, 0, 1, grid.length - 1, grid[0].length - 2)
  rounds = getout(grid, rounds, grid.length - 1, grid[0].length - 2, 0, 1)
  rounds = getout(grid, rounds, 0, 1, grid.length - 1, grid[0].length - 2)

  puts rounds
end

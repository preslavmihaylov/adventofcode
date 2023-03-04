#!/usr/env/bin ruby

class Player
  attr_reader :row, :col, :direction

  def initialize(row, col, direction)
    @row = row
    @col = col
    @direction = direction
  end

  def move(maze)
    nrow, ncol, ndirection = transform_around_cube(@row, @col, @direction)
    nrow, ncol = next_pos(maze, nrow, ncol, ndirection)

    if maze[nrow][ncol] == '#'
      Player.new(@row, @col, @direction)
    elsif maze[nrow][ncol] == '.'
      Player.new(nrow, ncol, ndirection)
    else
      raise ArgumentError, 'invalid state'
    end
  end

  def turn_left
    if @direction == 'U'
      Player.new(@row, @col, 'L')
    elsif @direction == 'R'
      Player.new(@row, @col, 'U')
    elsif @direction == 'D'
      Player.new(@row, @col, 'R')
    elsif @direction == 'L'
      Player.new(@row, @col, 'D')
    end
  end

  def turn_right
    if @direction == 'U'
      Player.new(@row, @col, 'R')
    elsif @direction == 'R'
      Player.new(@row, @col, 'D')
    elsif @direction == 'D'
      Player.new(@row, @col, 'L')
    elsif @direction == 'L'
      Player.new(@row, @col, 'U')
    end
  end

  private

  def next_pos(_maze, row, col, direction)
    nrow = 0
    ncol = 0
    if direction == 'U'
      nrow = row - 1
      ncol = col
    elsif direction == 'R'
      nrow = row
      ncol = col + 1
    elsif direction == 'D'
      nrow = row + 1
      ncol = col
    elsif direction == 'L'
      nrow = row
      ncol = col - 1
    else
      raise ArgumentError, "invalid direction #{direction}"
    end

    [nrow, ncol]
  end
end

class MoveCommand
  def initialize(times)
    @times = times
  end

  def apply(maze, player)
    for i in 1..@times
      player = player.move(maze)
    end

    player
  end
end

class TurnCommand
  def initialize(direction)
    @direction = direction
  end

  def apply(_maze, player)
    case @direction
    when 'R'
      player.turn_right
    when 'L'
      player.turn_left
    else
      raise ArgumentErro, "invalid direction #{@direction}"
    end
  end
end

def parse_maze(input)
  rows = []
  maxrow = 0
  input.split(/\n/).each do |row|
    splitted = row.split(//)
    maxrow = [maxrow, splitted.length].max

    # fill with whitespace until end of row for consistently sized grid
    rows.push(splitted + Array.new(maxrow - splitted.length) { ' ' })
  end

  rows
end

def parse_movements(input)
  moves = input.strip.split(/[RL]+/)
  turns = input.strip.split(/[0-9]+/).drop(1)

  movements = []
  while moves.length > 0
    movements.push(MoveCommand.new(moves.shift.to_i))
    movements.push(TurnCommand.new(turns.shift)) if turns.length > 0
  end

  movements
end

# mappings only work for my input
def transform_around_cube(row, col, direction)
  return 150 + (col - 50), -1, 'R' if row == 0 and col >= 50 and col < 100 and direction == 'U'
  return -1, 50 + (row - 150), 'D' if row >= 150 and row < 200 and col == 0 and direction == 'L'

  return 200, 0 + (col - 100), 'U' if row == 0 and col >= 100 and col < 150 and direction == 'U'
  return -1, 100 + (col - 0), 'D' if row == 199 and col >= 0 and col < 50 and direction == 'D'

  return 150 + (col - 50), 50, 'L' if row == 149 and col >= 50 and col < 100 and direction == 'D'
  return 150, 50 + (row - 150), 'U' if row >= 150 and row < 200 and col == 49 and direction == 'R'

  return 50 + (col - 0), 49, 'R' if row == 100 and col >= 0 and col < 50 and direction == 'U'
  return 99, 0 + (row - 50), 'D' if row >= 50 and row < 100 and col == 50 and direction == 'L'

  return 49 - (row - 100), 49, 'R' if row >= 100 and row < 150 and col == 0 and direction == 'L'
  return 149 - (row - 0), -1, 'R' if row >= 0 and row < 50 and col == 50 and direction == 'L'

  return 50, 100 + (row - 50), 'U' if row >= 50 and row < 100 and col == 99 and direction == 'R'
  return 50 + (col - 100), 100, 'L' if row == 49 and col >= 100 and col < 150 and direction == 'D'

  return 49 - (row - 100), 150, 'L' if row >= 100 and row < 150 and col == 99 and direction == 'R'
  return 149 - (row - 0), 100, 'L' if row >= 0 and row < 50 and col == 149 and direction == 'R'

  [row, col, direction]
end

def find_start(maze)
  maze.each_index do |row|
    maze[row].each_index do |col|
      return [row, col] if maze[row][col] == '.'
    end
  end

  raise ArgumentError, 'start position not found'
end

def read_input(filename = '../input.txt')
  inputs = File.read(filename).split(/\n\n/)

  maze = parse_maze(inputs[0])
  movements = parse_movements(inputs[1])

  [maze, movements]
end

if __FILE__ == $0
  maze, movements = read_input
  row, col = find_start(maze)
  player = Player.new(row, col, 'R')
  movements.each do |movement|
    player = movement.apply(maze, player)
  end

  score = 0
  score += 1000 * (player.row + 1)
  score += 4 * (player.col + 1)
  score += 0 if player.direction == 'R'
  score += 1 if player.direction == 'D'
  score += 2 if player.direction == 'L'
  score += 3 if player.direction == 'U'
  puts score
end

#!/usr/env/bin ruby

class Player
  attr_reader :row, :col, :direction

  def initialize(row, col, direction)
    @row = row
    @col = col
    @direction = direction
  end

  def move(maze)
    nrow, ncol = next_pos(maze, @row, @col)
    nrow, ncol = next_pos(maze, nrow, ncol) while is_invalid(maze, nrow, ncol)

    if maze[nrow][ncol] == '#'
      Player.new(@row, @col, @direction)
    elsif maze[nrow][ncol] == '.'
      Player.new(nrow, ncol, @direction)
    else
      raise ArgumentError, "invalid state - next pos is [#{maze[nrow][ncol]}]"
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

  def inspect
    "Player{row=#{@row}, col=#{@col}, direction=#{@direction}}"
  end

  private

  def next_pos(maze, row, col)
    nrow = 0
    ncol = 0
    if @direction == 'U'
      nrow = row - 1
      ncol = col
    elsif @direction == 'R'
      nrow = row
      ncol = col + 1
    elsif @direction == 'D'
      nrow = row + 1
      ncol = col
    elsif @direction == 'L'
      nrow = row
      ncol = col - 1
    else
      raise ArgumentError, "invalid direction #{@direction}"
    end

    nrow = 0 if nrow >= maze.length
    nrow = maze.length - 1 if nrow < 0
    ncol = 0 if ncol >= maze[nrow].length
    ncol = maze[nrow].length if ncol < 0

    [nrow, ncol]
  end

  def is_invalid(maze, row, col)
    maze[row][col] != '#' and maze[row][col] != '.'
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

  def inspect
    "#{@times}"
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

  def inspect
    "#{@direction}"
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

def print_state(maze, player)
  maze.each_index do |row|
    maze[row].each_index do |col|
      if player.row == row and player.col == col
        print '<' if player.direction == 'L'
        print '^' if player.direction == 'U'
        print '>' if player.direction == 'R'
        print 'v' if player.direction == 'D'
      else
        print maze[row][col]
      end
    end

    print "\n"
  end
end

if __FILE__ == $0
  maze, movements = read_input
  row, col = find_start(maze)
  player = Player.new(row, col, 'R')
  movements.each do |movement|
    player = movement.apply(maze, player)
    # print "\n\n"
    # print_state(maze, player)
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

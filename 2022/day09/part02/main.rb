#!/usr/bin/env ruby

require './types'

def to_dir(dir_str)
  case dir_str
  when 'U'
    :up
  when 'R'
    :right
  when 'D'
    :down
  when 'L'
    :left
  else
    raise ArgumentError, "invalid direction #{dir_str}"
  end
end

def read_input(filename = '../input.txt')
  File.readlines(filename)
      .map { |line| line.strip.split }
      .map { |tokens| Movement.new(to_dir(tokens[0]), tokens[1].to_i) }
end

def are_adjacent(p1, p2)
  (p1.row - p2.row).abs <= 1 and (p1.col - p2.col).abs <= 1
end

def move(head, direction)
  case direction
  when :up
    Point.new(head.row - 1, head.col)
  when :right
    Point.new(head.row, head.col + 1)
  when :down
    Point.new(head.row + 1, head.col)
  when :left
    Point.new(head.row, head.col - 1)
  else
    raise ArgumentError, "invalid direction #{direction}"
  end
end

# Use adjacent(head, tail)
def move_towards(tail, head)
  return tail if are_adjacent(tail, head)

  row = tail.row
  row += 1 if tail.row < head.row
  row -= 1 if tail.row > head.row

  col = tail.col
  col += 1 if tail.col < head.col
  col -= 1 if tail.col > head.col

  Point.new(row, col)
end

def simulate_rope(movements)
  rope = [Point.new(0, 0), Point.new(0, 0), Point.new(0, 0), Point.new(0, 0),
          Point.new(0, 0), Point.new(0, 0), Point.new(0, 0),
          Point.new(0, 0), Point.new(0, 0), Point.new(0, 0)]
  visited_positions = [rope.last]
  movements.each do |movement|
    for i in 1..movement.times
      rope[0] = move(rope[0], movement.direction)
      for i in 1..(rope.length - 1)
        rope[i] = move_towards(rope[i], rope[i - 1])
      end

      visited_positions.append(rope.last)
    end
  end

  visited_positions.uniq { |p| "#{p.row} #{p.col}" }
end

if __FILE__ == $0
  movements = read_input
  visited_positions = simulate_rope(movements)
  puts visited_positions.count
end

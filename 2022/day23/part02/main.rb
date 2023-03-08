#!/usr/env/bin ruby
require 'set'

def tokey(row, col)
  "#{row}:#{col}"
end

def torowcol(key)
  tokens = key.split(/:/)
  [tokens[0].to_i, tokens[1].to_i]
end

def read_input(filename = '../input.txt')
  field = File.read(filename).split(/\n/).map { |row| row.chars }

  elves = Set.new([])
  field.each_index do |row|
    field[row].each_index do |col|
      elves << tokey(row, col) if field[row][col] == '#'
    end
  end

  elves
end

# next_moves returns the three moves (row, col tuples) facing the
# row, col in the given direction in the order [next_move, diagonal1, diagonal2]
def next_moves(row, col, direction)
  case direction
  when 'N'
    [[row - 1, col], [row - 1, col - 1], [row - 1, col + 1]]
  when 'S'
    [[row + 1, col], [row + 1, col - 1], [row + 1, col + 1]]
  when 'W'
    [[row, col - 1], [row - 1, col - 1], [row + 1, col - 1]]
  when 'E'
    [[row, col + 1], [row - 1, col + 1], [row + 1, col + 1]]
  else
    raise ArgumentError, "Invalid move: #{direction}"
  end
end

def next_move(row, col, direction)
  moves = next_moves(row, col, direction)
  moves[0]
end

def any_elves_around_dir(elves, pos, direction)
  row, col = torowcol(pos)
  pos = next_moves(row, col, direction)
  pos.any? { |row, col| elves.include?(tokey(row, col)) }
end

def any_elves_around(elves, pos)
  any_elves_around_dir(elves, pos, 'N') or any_elves_around_dir(elves, pos, 'S') or
    any_elves_around_dir(elves, pos, 'W') or any_elves_around_dir(elves, pos, 'E')
end

def plan_movements(elves, directions)
  planned_pos = {}
  elves.each do |elf_pos|
    next unless any_elves_around(elves, elf_pos)

    row, col = torowcol(elf_pos)
    directions.each do |dir|
      next if any_elves_around_dir(elves, elf_pos, dir)

      nrow, ncol = next_move(row, col, dir)
      next_pos = tokey(nrow, ncol)

      planned_pos[next_pos] = [] if planned_pos[next_pos].nil?
      planned_pos[next_pos] << elf_pos
      break
    end
  end

  planned_pos
end

def execute_plan(elves, planned_pos)
  planned_pos.each do |to, froms|
    next if froms.length != 1

    from = froms[0]
    elves.delete(from)
    elves.add(to)
  end
end

def simulate(elves)
  directions = %w[N S W E]

  rounds = 1
  while true
    planned_pos = plan_movements(elves, directions)
    break if planned_pos == {}

    execute_plan(elves, planned_pos)
    directions = directions.rotate(1)

    rounds += 1
  end

  rounds
end

if __FILE__ == $0
  elves = read_input
  rounds = simulate(elves)
  puts rounds
end

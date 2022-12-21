#!/usr/env/bin ruby

$GRID_LENGTH = 7
$GRID_HEIGHT = 4000
$rocks = [
  [['#', '#', '#', '#']],
  [
    ['.', '#', '.'],
    ['#', '#', '#'],
    ['.', '#', '.']
  ],
  [
    ['.', '.', '#'],
    ['.', '.', '#'],
    ['#', '#', '#']
  ],
  [
    ['#'],
    ['#'],
    ['#'],
    ['#']
  ],
  [
    ['#', '#'],
    ['#', '#']
  ]
]

def read_input(filename = '../input.txt')
  File.read(filename).strip.split(//)
end

def print_grid(grid)
  height = count_height(grid)
  visible_area = 20
  start_row = ($GRID_HEIGHT - height - 10)
  end_row = start_row + visible_area

  for row in start_row..end_row
    print '|'
    for col in 0..6
      print grid[grid.length - 1 - row][col]
    end

    print "|\n"
  end

  print "+-------+\n"
end

def find_start_row(grid)
  row = 0
  while true
    break unless grid[row].any?('#')

    row += 1
  end

  row + 3
end

def draw_rock(grid, rock, row, col)
  row += (rock.length - 1)
  rock.each_index do |r_row|
    rock[r_row].each_index do |r_col|
      grid[row - r_row][col + r_col] = rock[r_row][r_col] if rock[r_row][r_col] == '#'
    end
  end
end

def clear_rock(grid, rock, row, col)
  row += (rock.length - 1)
  rock.each_index do |r_row|
    rock[r_row].each_index do |r_col|
      grid[row - r_row][col + r_col] = '.' if rock[r_row][r_col] == '#'
    end
  end
end

def move_sideways(grid, rock, row, col, movement)
  next_col = (movement == '>' ? col + 1 : col - 1)
  return col if next_col < 0
  return col if next_col + rock.last.length > $GRID_LENGTH

  rock.each_index do |r_row|
    # check for collisions on left of rock
    rock[r_row].each_index do |r_col|
      break if next_col > col
      next if rock[r_row][r_col] == '.'

      grid_row = row + rock.length - 1 - r_row
      grid_col = col + r_col - 1
      return col if rock[r_row][r_col] == '#' and grid[grid_row][grid_col] == '#'

      break
    end

    # check for collisions on right of rock
    rock[r_row].each_index.reverse_each do |r_col|
      break if next_col < col
      next if rock[r_row][r_col] == '.'

      grid_row = row + rock.length - 1 - r_row
      grid_col = col + r_col + 1
      return col if rock[r_row][r_col] == '#' and grid[grid_row][grid_col] == '#'

      break
    end
  end

  next_col
end

def can_move_down(grid, rock, row, col)
  return false if row == 0

  rock.each_index do |r_row|
    rock[r_row].each_index do |r_col|
      return false if grid[row + rock.length - 1 - r_row - 1][col + r_col] == '#' and rock[r_row][r_col] == '#'
    end
  end

  true
end

def count_height(grid)
  height = 0
  for row in 0..$GRID_HEIGHT
    return height unless grid[row].any?('#')

    height += 1
  end

  height
end

def simulate_falling_rocks(movements, times)
  grid = []
  for row in 0..$GRID_HEIGHT
    grid.push([])
    for col in 0..$GRID_LENGTH - 1
      grid.last.push('.')
    end
  end

  rock_index = 0
  move_index = 0
  for i in 1..times
    rock = $rocks[rock_index]
    row = find_start_row(grid)
    col = 2
    draw_rock(grid, rock, row, col)
    while true
      clear_rock(grid, rock, row, col)
      col = move_sideways(grid, rock, row, col, movements[move_index])
      move_index = (move_index + 1) % movements.length
      if can_move_down(grid, rock, row, col)
        row -= 1
        draw_rock(grid, rock, row, col)
      else
        draw_rock(grid, rock, row, col)
        break
      end
    end

    rock_index = (rock_index + 1) % $rocks.length
  end

  grid
end

if __FILE__ == $0
  movements = read_input
  grid = simulate_falling_rocks(movements, 2022)
  puts count_height(grid)
end

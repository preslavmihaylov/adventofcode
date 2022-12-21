#!/usr/env/bin ruby

$GRID_LENGTH = 7
$GRID_HEIGHT = 40
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

def count_height(grid, start_row)
  height = 0
  for row in start_row..$GRID_HEIGHT
    return height unless grid[row].any?('#')

    height += 1
  end

  start_row + height
end

def trim_grid_by(grid, rows_cnt)
  offset = rows_cnt
  for row in 0..$GRID_HEIGHT - offset
    for col in 0..$GRID_LENGTH - 1
      grid[row][col] = grid[row + offset][col]
    end
  end

  for row in $GRID_HEIGHT - offset..$GRID_HEIGHT
    for col in 0..$GRID_LENGTH - 1
      grid[row][col] = '.'
    end
  end
end

# "rock_index,move_index,top_pattern" = {last_height, step_no, top_pattern}
# if found
#   repeat_cycles = times - step_no
#   while times - i > repeat_cycles
#     height += curr - last_height
#     grid = top_pattern
#
# (there might be off by one errors but will adjust if anything doesnt work)
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
  acc_height = 0
  last_height = 0
  for i in 1..times
    start_row = 0
    height = count_height(grid, start_row)
    total_height = height + acc_height
    # if (acc_height + height) % 10_000 == 0
    #   time = Time.new
    print "#{total_height} (delta = #{total_height - last_height})\n"
    last_height = total_height
    # end

    if count_height(grid, start_row) > 30
      acc_height += 20
      trim_grid_by(grid, 20)
    end

    rock = $rocks[rock_index]
    row = find_start_row(grid)
    col = 2
    while true
      col = move_sideways(grid, rock, row, col, movements[move_index])
      move_index = (move_index + 1) % movements.length
      if can_move_down(grid, rock, row, col)
        row -= 1
      else
        draw_rock(grid, rock, row, col)
        start_row = row
        break
      end
    end

    rock_index = (rock_index + 1) % $rocks.length
  end

  acc_height + count_height(grid, 0)
end

if __FILE__ == $0
  movements = read_input('../input-example.txt')
  puts simulate_falling_rocks(movements, 2022)
end

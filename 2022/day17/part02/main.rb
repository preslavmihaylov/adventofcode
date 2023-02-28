#!/usr/env/bin ruby

$GRID_LENGTH = 7
$GRID_HEIGHT = 200
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

def move_sideways(grid, rock_idx, row, col, movement)
  next_col = (movement == '>' ? col + 1 : col - 1)
  return col if next_col < 0
  return col if next_col + $rocks[rock_idx].last.length > $GRID_LENGTH

  if rock_idx == 0
    return col + 1 if movement == '>' and grid[row][col + 4] != '#'
    return col - 1 if movement == '<' and grid[row][col - 1] != '#'
  elsif rock_idx == 1
    if movement == '>' and grid[row][col + 2] != '#' and grid[row + 1][col + 3] != '#' and grid[row + 2][col + 2] != '#'
      return col + 1
    end
    if movement == '<' and grid[row][col] != '#' and grid[row + 1][col - 1] != '#' and grid[row + 2][col] != '#'
      return col - 1
    end
  elsif rock_idx == 2
    if movement == '>' and grid[row][col + 3] != '#' and grid[row + 1][col + 3] != '#' and grid[row + 2][col + 3] != '#'
      return col + 1
    end
    if movement == '<' and grid[row][col - 1] != '#' and grid[row + 1][col + 1] != '#' and grid[row + 2][col + 1] != '#'
      return col - 1
    end
  elsif rock_idx == 3
    if movement == '>' and grid[row][col + 1] != '#' and grid[row + 1][col + 1] != '#' and grid[row + 2][col + 1] != '#' and grid[row + 3][col + 1] != '#'
      return col + 1
    end
    if movement == '<' and grid[row][col - 1] != '#' and grid[row + 1][col - 1] != '#' and grid[row + 2][col - 1] != '#' and grid[row + 3][col - 1] != '#'
      return col - 1
    end
  elsif rock_idx == 4
    return col + 1 if movement == '>' and grid[row][col + 2] != '#' and grid[row + 1][col + 2] != '#'
    return col - 1 if movement == '<' and grid[row][col - 1] != '#' and grid[row + 1][col - 1] != '#'
  end

  col
end

def can_move_down(grid, rock_idx, row, col)
  return false if row == 0
  if rock_idx == 0
    return (grid[row - 1][col] != '#' and grid[row - 1][col + 1] != '#' and grid[row - 1][col + 2] != '#' and grid[row - 1][col + 3] != '#')
  end

  return (grid[row][col] != '#' and grid[row - 1][col + 1] != '#' and grid[row][col + 2] != '#') if rock_idx == 1

  if rock_idx == 2
    return (grid[row - 1][col] != '#' and grid[row - 1][col + 1] != '#' and grid[row - 1][col + 2] != '#')
  end

  return (grid[row - 1][col] != '#') if rock_idx == 3
  return (grid[row - 1][col] != '#' and grid[row - 1][col + 1] != '#') if rock_idx == 4

  raise "invalid state - invalid rock index #{rock_idx}"
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

def serialize(grid, rock_idx, move_idx)
  r = "|#{rock_idx}|#{move_idx}|"
  grid.each do |row|
    row.each do |str|
      r += str
    end
  end

  r
end

def simulate_falling_rocks(movements, times)
  seen_states = {}

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
  found_loop = false
  for i in 1..times
    break if i > times

    start_row = 0
    # height = count_height(grid, start_row)
    # total_height = height + acc_height
    # if (acc_height + height) % 10_000 == 0
    #   time = Time.new
    # print "#{total_height} (delta = #{total_height - last_height})\n"
    # last_height = total_height
    # end
    puts acc_height

    if count_height(grid, start_row) > 120
      acc_height += 20
      trim_grid_by(grid, 20)
    end

    print "i=#{i}\n"
    curr_state = serialize(grid, rock_index, move_index)
    if seen_states.key?(curr_state) and !found_loop
      print "acc_height=#{acc_height}, i=#{i}, l_acc_height=#{seen_states[curr_state][0]}, l_i=#{seen_states[curr_state][1]}\n"
      # return
      delta_height = acc_height - seen_states[curr_state][0] # 0 - acc_height
      delta_i = i - seen_states[curr_state][1] # 1 - last step i
      if delta_i > 2000
        while i + delta_i < times
          times -= delta_i
          acc_height += delta_height
        end

        found_loop = true
        # seen_states = {}
      end
    else
      seen_states[curr_state] = [acc_height, i]
    end

    rock = $rocks[rock_index]
    row = find_start_row(grid)
    col = 2
    while true
      col = move_sideways(grid, rock_index, row, col, movements[move_index])
      move_index = (move_index + 1) % movements.length
      if can_move_down(grid, rock_index, row, col)
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
  # expected for input-2.txt - 1580758017509
  movements = read_input
  puts simulate_falling_rocks(movements, 1_000_000_000_000)
end

#!/usr/bin/env ruby

def read_input(filename = '../input.txt')
  File.readlines(filename).map { |line| line.strip.split(//) }
end

def is_visible_dir(grid, row, col, _mutator, _condition)
  tree = grid[row][col].to_i
  row, col = _mutator.call(row, col)

  while _condition.call(row, col)
    return false if tree <= grid[row][col].to_i

    row, col = _mutator.call(row, col)
  end

  true
end

def is_visible_left(grid, row, col)
  is_visible_dir(grid, row, col,
                 ->(_row, _col) { return _row, _col - 1 },
                 ->(_row, _col) { _col >= 0 })
end

def is_visible_right(grid, row, col)
  is_visible_dir(grid, row, col,
                 ->(_row, _col) { return _row, _col + 1 },
                 ->(_row, _col) { _col < grid[_row].length })
end

def is_visible_top(grid, row, col)
  is_visible_dir(grid, row, col,
                 ->(_row, _col) { return _row - 1, _col },
                 ->(_row, _col) { _row >= 0 })
end

def is_visible_bottom(grid, row, col)
  is_visible_dir(grid, row, col,
                 ->(_row, _col) { return _row + 1, _col },
                 ->(_row, _col) { _row < grid.length })
end

def is_visible(grid, row, col)
  is_visible_top(grid, row, col) ||
    is_visible_right(grid, row, col) ||
    is_visible_bottom(grid, row, col) ||
    is_visible_left(grid, row, col)
end

if __FILE__ == $0
  grid = read_input

  visible_trees = 0
  grid.each_index do |row|
    grid[row].each_index do |col|
      visible_trees += 1 if is_visible(grid, row, col)
    end
  end

  puts visible_trees
end

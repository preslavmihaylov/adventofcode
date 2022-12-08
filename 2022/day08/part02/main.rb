#!/usr/bin/env ruby

def read_input(filename = '../input.txt')
  File.readlines(filename).map { |line| line.strip.split(//) }
end

def calc_visibility_dir(grid, row, col, _mutator, _condition)
  tree = grid[row][col].to_i
  row, col = _mutator.call(row, col)

  visibility = 0
  while _condition.call(row, col)
    visibility += 1
    return visibility if tree <= grid[row][col].to_i

    row, col = _mutator.call(row, col)
  end

  visibility
end

def calc_visibility_left(grid, row, col)
  calc_visibility_dir(grid, row, col,
                      ->(_row, _col) { return _row, _col - 1 },
                      ->(_row, _col) { _col >= 0 })
end

def calc_visibility_right(grid, row, col)
  calc_visibility_dir(grid, row, col,
                      ->(_row, _col) { return _row, _col + 1 },
                      ->(_row, _col) { _col < grid[_row].length })
end

def calc_visibility_top(grid, row, col)
  calc_visibility_dir(grid, row, col,
                      ->(_row, _col) { return _row - 1, _col },
                      ->(_row, _col) { _row >= 0 })
end

def calc_visibility_bottom(grid, row, col)
  calc_visibility_dir(grid, row, col,
                      ->(_row, _col) { return _row + 1, _col },
                      ->(_row, _col) { _row < grid.length })
end

def scenic_score(grid, row, col)
  calc_visibility_top(grid, row, col) *
    calc_visibility_right(grid, row, col) *
    calc_visibility_bottom(grid, row, col) *
    calc_visibility_left(grid, row, col)
end

if __FILE__ == $0
  grid = read_input

  max_scenic_score = 0
  grid.each_index do |row|
    grid[row].each_index do |col|
      max_scenic_score = [max_scenic_score, scenic_score(grid, row, col)].max
    end
  end

  puts max_scenic_score
end

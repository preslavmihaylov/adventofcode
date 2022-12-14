#!/usr/bin/env ruby

class Grid
  attr_accessor :cells

  def initialize(rows, cols)
    @cells = []
    for row in 1..rows
      @cells.push([])
      for col in 1..cols
        @cells.last.push('.')
      end
    end
  end

  def to_s
    @cells.each_index do |row|
      # encountered_smth = false
      @cells[row].each_index do |col|
        print @cells[row][col] if col > 400
      end

      print "\n"
    end
  end
end

def read_input(filename = '../input.txt')
  rocks = []
  File.readlines(filename).each do |line|
    rocks.push(line.strip.split(/ -> /).map { |p1| p1.split(/,/).map { |p2| p2.to_i } })
  end

  rocks
end

def populate_grid(grid, rocks)
  grid.cells[0][500] = '+'
  rocks.each do |rock_path|
    for i in 0..rock_path.length - 2
      rock_start = rock_path[i]
      rock_end = rock_path[i + 1]

      row_min = [rock_start[1], rock_end[1]].min
      row_max = [rock_start[1], rock_end[1]].max
      col_min = [rock_start[0], rock_end[0]].min
      col_max = [rock_start[0], rock_end[0]].max
      for row in row_min..row_max
        for col in col_min..col_max
          grid.cells[row][col] = '#'
        end
      end
    end
  end
end

def simulate_sand(grid)
  while true
    sand_col = 500
    sand_row = 0
    while true
      return if sand_row + 1 >= grid.cells.length

      if grid.cells[sand_row + 1][sand_col] == '.'
        sand_row += 1
      elsif grid.cells[sand_row + 1][sand_col - 1] == '.'
        sand_row += 1
        sand_col -= 1
      elsif grid.cells[sand_row + 1][sand_col + 1] == '.'
        sand_row += 1
        sand_col += 1
      else
        grid.cells[sand_row][sand_col] = 'O'
        break
      end
    end
  end
end

def count_sand(grid)
  sand_cnt = 0
  grid.cells.each_index do |row|
    grid.cells[row].each_index do |col|
      sand_cnt += 1 if grid.cells[row][col] == 'O'
    end
  end

  sand_cnt
end

if __FILE__ == $0
  rocks = read_input

  grid = Grid.new(200, 600)
  populate_grid(grid, rocks)
  simulate_sand(grid)
  puts count_sand(grid)
end

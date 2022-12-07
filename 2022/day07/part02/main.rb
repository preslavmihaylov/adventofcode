#!/usr/bin/env ruby

require './types'

TOTAL_DISK_SPACE = 70_000_000
FREE_SPACE_REQUIRED = 30_000_000

def read_input(filename = '../input.txt')
  # skip first line which is "cd /"
  File.readlines(filename).map { |l| l.strip }.drop(1)
end

def is_cmd(line)
  line[0] == '$'
end

def extract_cmd(line)
  tokens = line.split

  # examples - "$ cd ..", "$ ls"
  Command.new(tokens[1], tokens.length > 2 ? [tokens[2]] : [])
end

def process_cmd(cmd, dir)
  return dir if cmd.name != 'cd'
  return dir.parent if cmd.args[0] == '..'

  next_dir = Directory.new(dir, cmd.args[0])
  dir.add_dir(next_dir)
  next_dir
end

def process_ls_output(out, dir)
  tokens = out.split
  return dir if tokens[0] == 'dir'

  f = File.new(tokens[1], tokens[0].to_i)
  dir.add_file(f)
  dir
end

def process(lines)
  root = Directory.new(nil, '/')
  curr_dir = root
  lines.each do |line|
    curr_dir = process_cmd(extract_cmd(line), curr_dir) if is_cmd(line)
    curr_dir = process_ls_output(line, curr_dir) unless is_cmd(line)
  end

  root
end

def dirs_less_than(root, max_size)
  small_dirs = []
  small_dirs.append(root) if root.total_size <= max_size
  root.dirs.each do |dir|
    small_dirs += dirs_less_than(dir, max_size)
  end

  small_dirs
end

if __FILE__ == $0
  lines = read_input
  root = process(lines)

  target_space = FREE_SPACE_REQUIRED - (TOTAL_DISK_SPACE - root.total_size)

  all_dirs = dirs_less_than(root, TOTAL_DISK_SPACE)
  smaller_dirs = dirs_less_than(root, target_space)
  target_dirs = all_dirs - smaller_dirs

  puts target_dirs.sort_by { |dir| dir.total_size }.first.total_size
end

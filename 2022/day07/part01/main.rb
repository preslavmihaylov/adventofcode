#!/usr/bin/env ruby

class Command
  attr_reader :name, :args

  def initialize(name, args)
    @name = name
    @args = args
  end
end

class File
  attr_reader :name, :size

  def initialize(name, size)
    @name = name
    @size = size
  end
end

class Directory
  attr_reader :parent, :name, :dirs

  def initialize(parent, name)
    @parent = parent
    @name = name
    @dirs = []
    @files = []
  end

  def add_dir(dir)
    @dirs.append(dir)
  end

  def add_file(file)
    @files.append(file)
  end

  def total_size
    size = @files.inject(0) { |sum, f| sum += f.size }
    size += @dirs.inject(0) { |sum, dir| sum += dir.total_size }
    size
  end

  # used for debugging
  def to_s
    to_s_with_prefix
  end

  def to_s_with_prefix(prefix = '')
    r = "#{prefix}#{name}\n"
    @files.each do |file|
      r += "#{prefix}\t[F] #{file.name} (#{file.size})\n"
    end

    @dirs.each do |dir|
      r += dir.to_s_with_prefix(prefix + "\t")
    end

    r
  end
end

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

def find_small_dirs(root, max_size)
  small_dirs = []
  small_dirs.append(root) if root.total_size <= max_size
  root.dirs.each do |dir|
    small_dirs += find_small_dirs(dir, max_size)
  end

  small_dirs
end

if __FILE__ == $0
  lines = read_input
  root = process(lines)
  small_dirs = find_small_dirs(root, 100_000)
  total_size = small_dirs.inject(0) { |sum, dir| sum + dir.total_size }
  puts total_size
end

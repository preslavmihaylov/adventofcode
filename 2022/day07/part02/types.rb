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
end

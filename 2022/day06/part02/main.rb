#!/bin/env ruby

def is_marker(str)
  return true if str.chars.to_a.uniq.length == str.length

  false
end

def find_marker_idx(input, marker_length)
  input.split('').each_index do |idx|
    break if idx + marker_length > input.length
    return idx + marker_length if is_marker(input[idx, marker_length])
  end
end

if __FILE__ == $0
  input = File.read('../input.txt').strip
  marker_idx = find_marker_idx(input, 14)
  puts marker_idx
end

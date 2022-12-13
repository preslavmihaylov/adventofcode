#!/usr/bin/env ruby

def read_input(filename = '../input.txt')
  contents = File.read(filename)
  contents.split(/\n\n/).map { |pairs| pairs.split(/\n/).map { |pair| eval(pair) } }
end

def compare_ints(pair1, pair2)
  pair1 - pair2
end

def compare_lists(pair1, pair2)
  pair1.each_index do |idx|
    break if idx >= pair2.length

    elem1 = pair1[idx]
    elem2 = pair2[idx]
    elem1 = [elem1] if elem1.is_a?(Integer) and elem2.is_a?(Array)
    elem2 = [elem2] if elem1.is_a?(Array) and elem2.is_a?(Integer)

    result = 0
    result = compare_lists(elem1, elem2) if elem1.is_a?(Array) and elem2.is_a?(Array)
    result = compare_ints(elem1, elem2) if elem1.is_a?(Integer) and elem2.is_a?(Integer)
    return result if result != 0
  end

  pair1.length - pair2.length
end

if __FILE__ == $0
  puts read_input.
    each_with_index.
    map { |pair, idx| compare_lists(pair[0], pair[1]) < 0 ? idx + 1 : 0 }.
    sum
end

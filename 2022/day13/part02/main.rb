#!/usr/bin/env ruby

def read_input(filename = '../input.txt')
  contents = File.read(filename)
  contents.split(/\n/)
          .select { |pair| !pair.strip.empty? }
          .map { |pair| eval(pair) }
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
  pairs = read_input
  pairs.push([[2]])
  pairs.push([[6]])

  puts pairs.sort(&->(p1, p2) { compare_lists(p1, p2) })
            .each_with_index
            .select { |pair, _| [[[2]], [[6]]].include?(pair) }
            .map { |_, idx| idx + 1 }
            .inject(:*)
end

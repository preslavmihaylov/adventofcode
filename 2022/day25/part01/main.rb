#!/usr/env/bin ruby

def digitFromSNAFU(digit)
  case digit
  when '2', '1', '0'
    digit.to_i
  when '-'
    -1
  when '='
    -2
  end
end

def digitToSNAFU(digit)
  case digit
  when '0', '1', '2'
    digit
  when '3'
    '='
  when '4'
    '-'
  end
end

def fromSNAFU(input)
  result = 0
  pos = 0
  input.reverse.each_char do |digit|
    result += digitFromSNAFU(digit) * 5**pos
    pos += 1
  end

  result
end

def toSNAFU(input)
  result = ''
  while input > 0
    snafu = digitToSNAFU((input % 5).to_s)
    result += snafu

    input -= digitFromSNAFU(snafu)
    input /= 5
  end

  result.reverse
end

def read_input(filename = '../input.txt')
  File.readlines(filename).each.map { |l| fromSNAFU(l.strip) }
end

if __FILE__ == $0
  nums = read_input
  puts toSNAFU(nums.sum)
end

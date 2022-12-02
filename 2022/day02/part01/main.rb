#!/usr/bin/env ruby

def parse_play(letter)
  return :rock if %w[A X].include?(letter)
  return :paper if %w[B Y].include?(letter)
  return :scissors if %w[C Z].include?(letter)

  :unknown
end

def read_input(_filename = 'input.txt')
  file = File.open(_filename)

  plays = []
  file.each_line do |line|
    plays.append(line.split(' ').map { |letter| parse_play(letter) })
  end

  plays
end

def is_draw(theirs, mine)
  theirs == mine
end

def is_win(theirs, mine)
  return true if theirs == :rock and mine == :paper
  return true if theirs == :paper and mine == :scissors
  return true if theirs == :scissors and mine == :rock

  false
end

def score_for(choice)
  return 1 if choice == :rock
  return 2 if choice == :paper
  return 3 if choice == :scissors

  0
end

if __FILE__ == $0
  games = read_input

  score = 0
  games.each do |game|
    theirs = game[0]
    mine = game[1]

    score += 3 if is_draw(theirs, mine)
    score += 6 if is_win(theirs, mine)
    score += score_for(mine)
  end

  puts score
end

#!/usr/bin/env ruby

def parse_play(letter)
  return :rock if letter == 'A'
  return :paper if letter == 'B'
  return :scissors if letter == 'C'

  return :lose if letter == 'X'
  return :draw if letter == 'Y'
  return :win if letter == 'Z'

  :unknown
end

def read_input(_filename = 'input.txt')
  file = File.open(_filename)

  games = []
  file.each_line do |line|
    games.append(line.split(' ').map { |letter| parse_play(letter) })
  end

  games
end

def derive_my_play(theirs, outcome_wanted)
  return theirs if outcome_wanted == :draw

  if outcome_wanted == :lose
    return :rock if theirs == :paper
    return :paper if theirs == :scissors
    return :scissors if theirs == :rock
  else
    return :rock if theirs == :scissors
    return :paper if theirs == :rock
    return :scissors if theirs == :paper
  end
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
    outcome_wanted = game[1]
    mine = derive_my_play(theirs, outcome_wanted)

    score += 3 if is_draw(theirs, mine)
    score += 6 if is_win(theirs, mine)
    score += score_for(mine)
  end

  puts score
end

import Data.List.Split
import Data.List (nub)

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = length antinodes
  where
    matrix = lines input
    poss = allPositions matrix
    allSymbols = findAllSymbols matrix poss
    validPairs = getPairs matrix allSymbols
    antinodes = 
      nub 
      $ filter (\p -> isInBounds matrix p) 
      $ genAntinodes matrix validPairs

genAntinodes _ [] = []
genAntinodes matrix pairs = [(r1, c1)] ++ antinodes ++ (genAntinodes matrix (tail pairs))
  where
    pair = head pairs
    ((r1, c1), (r2, c2)) = pair
    (dr, dc) = (r1-r2, c1-c2)
    antinodes = [(r1+dr*rep, c1+dc*rep) | rep <- [1..50]]
    

getPairs matrix symbols =
  [((r1, c1), (r2, c2)) |
   (r1, c1) <- symbols, 
   (r2, c2) <- symbols,
   (not (r1 == r2 && c1 == c2)) && 
    (symbolAt matrix r1 c1) == (symbolAt matrix r2 c2)]

symbolAt matrix r c = ((matrix!!r)!!c)

findAllSymbols matrix ((row, col):poss)
  | null poss = if isSymbol then [(row, col)] else []
  | isSymbol  = (row, col):(findAllSymbols matrix poss)
  | otherwise = findAllSymbols matrix poss
  where
    isSymbol = ((matrix!!row)!!col) /= '.'

allPositions matrix = 
  [(row, col) | 
    row <- [0..(length matrix)-1], 
    col <- [0..(length (matrix !! 0))-1]]

isInBounds matrix (r,c) = 
  r >= 0 && r < (length matrix) && c >= 0 && c < (length (matrix !! 0))

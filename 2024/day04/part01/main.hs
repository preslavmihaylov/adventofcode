main = do
  input <- readFile "../input.txt"
  let matrix = lines input
   in print $ findXmas matrix $ allPositions matrix

findXmas matrix [] = 0
findXmas matrix (pos:poss) = (allXmases matrix pos) + findXmas matrix poss

allXmases matrix pos = sum [1 | dir <- dirs, isXmasInDir matrix pos dir]
  where
    dirs = [(0, -1), (0, 1), (-1, 0), (1, 0), (-1, -1), (1, 1), (-1, 1), (1, -1)]

isXmasInDir matrix (r, c) (dr, dc) = 
  allInBounds &&
  ((matrix !! r) !! c) == 'X' &&
  ((matrix !! (r+dr)) !! (c+dc)) == 'M' &&
  ((matrix !! (r+2*dr)) !! (c+2*dc)) == 'A' &&
  ((matrix !! (r+3*dr)) !! (c+3*dc)) == 'S'
  where
    inBounds (row, col) = row >= 0 && row < (length matrix) && col >= 0 && col < (length (head matrix))
    allInBounds = 
      inBounds (r, c) && inBounds (r+dr, c+dc) && 
      inBounds (r+2*dr, c+2*dc) && inBounds (r+3*dr, c+3*dc)

allPositions xss = 
  [(r, c) | 
    r <- [0..(length xss - 1)], 
    c <- [0..(length (head xss) - 1)]]

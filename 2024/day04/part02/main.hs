import Text.Regex.Posix

main = do
  input <- readFile "../input.txt"
  let matrix = lines input
   in print $ findXmas matrix $ allPositions matrix

findXmas matrix [] = 0
findXmas matrix (pos:poss) = (if isXmas matrix pos then 1 else 0) + (findXmas matrix poss)

isXmas matrix (r, c) = isStrInAllDirs matrix (r, c) "MAS" || isStrInAllDirs matrix (r, c) "SAM"

isStrInAllDirs matrix (r, c) str = 
  ((isStrInDir matrix (r, c) (1, 1, str)) || (isStrInDir matrix (r, c) (-1, -1, str))) &&
  ((isStrInDir matrix (r, c) (1, -1, str)) || (isStrInDir matrix (r, c) (-1, 1, str)))

isStrInDir matrix (r, c) (dr, dc, str) = 
  allInBounds &&
  ((matrix !! (r-dr)) !! (c-dc)) == (str!!0) &&
  ((matrix !! r) !! c) == (str!!1) &&
  ((matrix !! (r+dr)) !! (c+dc)) == (str!!2)
  where
    inBounds (row, col) = row >= 0 && row < (length matrix) && col >= 0 && col < (length (head matrix))
    allInBounds = inBounds (r-dr, c-dc) && inBounds (r, c) && inBounds (r+dr, c+dc)

allPositions xss = 
  [(r, c) | 
    r <- [0..(length xss - 1)], 
    c <- [0..(length (head xss) - 1)]]

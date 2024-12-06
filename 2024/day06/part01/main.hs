import Debug.Trace

main = do
  input <- readFile "../input.txt"
  let matrix = lines input
      startingPos = (findStartingPos matrix $ allPositions matrix)
      in print $ solve matrix [] startingPos "up" False

solve _ _ _ _ True = 0
solve matrix visited spos dir _ =
  dist + (solve matrix nvisited npos (nextDir dir) isOutside)
  where
    (nvisited, npos, dist, isOutside) = findNextTrajectory matrix visited spos dir 0

findNextTrajectory matrix visited (row, col) dir dist =
  if isNextPosOutside || isNextPosRoadblock
     then (visited, (row, col), dist, isNextPosOutside)
     else findNextTrajectory matrix ((nrow, ncol):visited) (nrow, ncol) dir nextDist
  where
    (nrow, ncol)
      | dir == "up"    = (row-1, col)
      | dir == "right" = (row, col+1)
      | dir == "down"  = (row+1, col)
      | otherwise      = (row, col-1)
    isNextPosRoadblock = ((matrix!!nrow)!!ncol) == '#'
    isNextPosOutside = not $ isInBounds matrix (nrow, ncol)
    nextDist = if elem (nrow, ncol) visited then dist else dist+1

nextDir dir
  | dir == "up" = "right"
  | dir == "right" = "down"
  | dir == "down" = "left"
  | dir == "left" = "up"

findStartingPos matrix (cpos:poss) =
  if isStartingPos then cpos else findStartingPos matrix poss
  where
    (row, col) = cpos
    isStartingPos = ((matrix!!row)!!col) == '^'

allPositions xss = 
  [(r, c) | 
    r <- [0..(length xss - 1)], 
    c <- [0..(length (head xss) - 1)]]
    
isInBounds matrix (row, col) = row >= 0 && row < (length matrix) && col >= 0 && col < (length (head matrix))

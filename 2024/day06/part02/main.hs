import qualified Data.Set as Set

main = do
  input <- readFile "../input.txt"
  let matrix = lines input
      spos = (findStartingPos matrix $ allPositions matrix)
      (initPath, _) = findFullPath matrix (-1,-1) Set.empty spos "up" False False
      in print $ Set.size $ Set.fromList $ buildLoops matrix spos (Set.toList initPath)


buildLoops _ _ [] = []
buildLoops matrix spos (vpos:npath) = 
  if isInLoop && (spos /= (row,col)) then (row,col):nextLoopResult else nextLoopResult
  where
    (row, col, _) = vpos
    (_, isInLoop) = findFullPath matrix (row, col) Set.empty spos "up" False False
    nextLoopResult = buildLoops matrix spos npath

findFullPath matrix obstruction visited spos dir isOutside isInLoop
  | isOutside || isInLoop = (visited, isInLoop)
  | otherwise             = findFullPath matrix obstruction nvisited npos (nextDir dir) nextIsOutside nextIsInLoop
  where
    (nvisited, npos, nextIsOutside, nextIsInLoop) = findNextTrajectory matrix obstruction visited spos dir

findNextTrajectory matrix obstruction visited (row, col) dir =
  if isNextPosOutside || isNextPosRoadblock || isNextPosObstruction || isInLoop
     then (visited, (row, col), isNextPosOutside, isInLoop)
     else findNextTrajectory matrix obstruction nvisited (nrow, ncol) dir
  where
    (nrow, ncol)
      | dir == "up"    = (row-1, col)
      | dir == "right" = (row, col+1)
      | dir == "down"  = (row+1, col)
      | otherwise      = (row, col-1)
    isNextPosRoadblock = ((matrix!!nrow)!!ncol) == '#'
    isNextPosObstruction = (nrow, ncol) == obstruction
    isNextPosOutside = not $ isInBounds matrix (nrow, ncol)
    nvisited = Set.insert (nrow, ncol, dir) visited
    isInLoop = Set.member (nrow, ncol, dir) visited

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
    
isInBounds matrix (row, col) = 
  row >= 0 && row < (length matrix) && col >= 0 && col < (length (head matrix))

import Data.List.Split (splitOn)
import Debug.Trace

-- input_file = "../example_input.txt"
input_file = "../input.txt"

-- grid_size = 7
grid_size = 71

start_pos = (0,0)
end_pos = (grid_size-1, grid_size-1)

main = do
  input <- readFile input_file
  print $ solve input

solve input = (show (snd cutoffByte)) ++ "," ++ (show (fst cutoffByte))
  where
    toTuple v = (read y :: Int, read x :: Int)
      where [x, y] = splitOn "," v
    corruptedBs = map toTuple $ lines input
    cutoffByte = findCutoffRoute corruptedBs (0, (length corruptedBs) - 1)

findCutoffRoute corruptedBs (start, end)
  | start >= end = corruptedBs !! (start-1)
  | exitExists = findCutoffRoute corruptedBs (mid+1, end)
  | otherwise  = findCutoffRoute corruptedBs (start, mid)
  where
    mid = (start+end) `div` 2
    cutoffBs = take mid corruptedBs
    exitExists = isExitPossible cutoffBs

isExitPossible corruptedBs = steps /= -1
  where steps = findMinExit corruptedBs [] [([], start_pos, 0)]

findMinExit corruptedBs visited [] = -1
findMinExit corruptedBs visited ((path, pos,i):queue)
  | pos == end_pos         = i 
  | not $ isInBounds pos   = findMinExit corruptedBs visited queue
  | pos `elem` corruptedBs = findMinExit corruptedBs visited queue
  | pos `elem` visited     = findMinExit corruptedBs visited queue
  | otherwise              = findMinExit corruptedBs nvisited nqueue
  where 
    (row, col) = pos
    nvisited = pos:visited
    npath = path ++ [pos]
    nqueue = queue ++ 
      [(npath, (row-1, col), i+1)] ++ 
      [(npath, (row, col+1), i+1)] ++ 
      [(npath, (row+1, col), i+1)] ++ 
      [(npath, (row, col-1), i+1)]

isInBounds (row, col) = 
  row >= 0 && row < grid_size && col >= 0 && col < grid_size

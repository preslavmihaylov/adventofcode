import Data.List.Split (splitOn)
import Debug.Trace

-- input_file = "../example_input.txt"
input_file = "../input.txt"

-- grid_size = 7
grid_size = 71

-- first_nbytes = 12
first_nbytes = 1024

start_pos = (0,0)
end_pos = (grid_size-1, grid_size-1)

main = do
  input <- readFile input_file
  print $ solve input

solve input = findMinExit corruptedBs [] [([], start_pos, 0)]
  where
    toTuple v = (read y :: Int, read x :: Int)
      where [x, y] = splitOn "," v
    corruptedBs = take first_nbytes $ map toTuple $ lines input

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

isInBounds (row, col) = row >= 0 && row < grid_size && col >= 0 && col < grid_size

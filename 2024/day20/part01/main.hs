import qualified Data.Set as Set

main = do
  input <- readFile "../input.txt"
  print $ solve input

-- example input
-- saved_time_offset = 0

-- input
saved_time_offset = 100

solve input = result
  where
    matrix = lines input
    poss = allPositions matrix
    (sr,sc) = findCell matrix 'S' poss
    epos = findCell matrix 'E' poss
    squeue = [(sr,sc,0)]
    spathCnt = shortestPath matrix squeue Set.empty (0,0) epos 1000000000
    spathWithOffset = spathCnt-saved_time_offset+1
    cposs = findAllCheatablePoss matrix
    toShortestPathWithCheat cpos = 
      shortestPath matrix squeue Set.empty cpos epos spathWithOffset
    result = length $ filter (/=(-1)) $ map toShortestPathWithCheat cposs

shortestPath _ [] _ _ _ _ = -1
shortestPath matrix queue visited cheatPos tpos maxcnt
  | cnt >= maxcnt                        = -1
  | (r,c) == (er, ec)                    = cnt
  | not $ isInBounds matrix (r,c)        = 
    shortestPath matrix squeue visited cheatPos tpos maxcnt
  | (r,c) /= (crow, ccol) && cell == '#' = 
    shortestPath matrix squeue visited cheatPos tpos maxcnt
  | Set.member (r,c) visited             = 
    shortestPath matrix squeue visited cheatPos tpos maxcnt
  | otherwise                            = 
    shortestPath matrix nqueue nvisited cheatPos tpos maxcnt
  where
    (er,ec) = tpos
    (crow, ccol) = cheatPos
    (r,c,cnt) = last queue
    squeue = init queue
    nvisited = Set.insert (r,c) visited
    cell = (matrix!!r)!!c
    ncnt = cnt+1
    nqueue = (r-1,c,ncnt):(r,c+1,ncnt):(r+1,c,ncnt):(r,c-1,ncnt):squeue

findCell matrix tcell ((r,c):poss)
  | cell == tcell = (r,c)
  | otherwise   = findCell matrix tcell poss
  where
    cell = (matrix!!r)!!c

findAllCheatablePoss matrix = 
  filter isNotSurroundedByWalls 
  $ filter isWall 
  $ filter notEdge 
  $ allPositions matrix
  where
    notEdge (r,c) = 
      r /= 0 && r /= (length matrix)-1 && c /= 0 && c /= (length (matrix!!0))-1
    isWall (r,c) = ((matrix!!r)!!c) == '#'
    isNotSurroundedByWalls (r,c) = wallsCnt <= 2
      where
        isWall (r,c) = ((matrix!!r)!!c) == '#'
        wallsCnt = length $ filter isWall [(r-1,c),(r,c+1),(r+1,c),(r,c-1)]

allPositions matrix = 
  [(r,c) | r <- [0..(length matrix)-1], c <- [0..(length (matrix!!0))-1]]

isInBounds matrix (r,c) = 
  r >= 0 && r < (length matrix) && c >= 0 && c < (length (matrix!!r))

import qualified Data.Set as Set

main = do
  input <- readFile "../input.txt"
  print $ solve input

-- example input
-- saved_time_offset = 50

-- input
saved_time_offset = 100

solve input = length cheats
  where
    matrix = lines input
    poss = allPositions matrix
    (sr,sc) = findCell matrix 'S' poss
    epos = findCell matrix 'E' poss
    squeue = [(sr,sc,0)]
    spath = spathWithDists $ shortestPath matrix squeue Set.empty epos 1000000000
    cheats = findCheats spath

findCheats [] = Set.empty
findCheats ((r,c,dist):path) = Set.union (Set.fromList cheats) ncheats
  where
    isViableCheat (nr,nc,ndist) = isValid && enoughSavedDist
      where
        md = manhattanDist (r,c) (nr,nc)
        isValid = md <= 20
        timeWithCheat = ndist + md
        savedTime = dist - timeWithCheat
        enoughSavedDist = savedTime >= 100

    cheats = map (\(nr,nc,_) -> (r,c,nr,nc)) $ filter isViableCheat path
    ncheats = findCheats path

spathWithDists [] = []
spathWithDists ((r,c):path) = (r,c,(length path)):spathWithDists path

manhattanDist (r1,c1) (r2,c2) = abs (r1-r2) + abs (c1-c2)

shortestPath matrix queue visited tpos maxcnt
  | (r,c) == (er, ec)                    = [(r,c)]
  | not $ isInBounds matrix (r,c)        = 
    shortestPath matrix squeue visited tpos maxcnt
  | cell == '#' = 
    shortestPath matrix squeue visited tpos maxcnt
  | Set.member (r,c) visited             = 
    shortestPath matrix squeue visited tpos maxcnt
  | otherwise                            = 
    (r,c):shortestPath matrix nqueue nvisited tpos maxcnt
  where
    (er,ec) = tpos
    (r,c,cnt) = last queue
    manhattanDist = abs (r-er) + abs (c-ec)
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

allPositions matrix = 
  [(r,c) | r <- [0..(length matrix)-1], c <- [0..(length (matrix!!0))-1]]

isInBounds matrix (r,c) = 
  r >= 0 && r < (length matrix) && c >= 0 && c < (length (matrix!!r))

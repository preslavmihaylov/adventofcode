import qualified Data.Set as Set
import Data.Heap (Heap)
import qualified Data.Heap as Heap

max_cost = maxBound :: Int

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = sp
  where
    grid = lines input
    coords = allCoords grid
    start = findCell grid 'S' coords
    end = findCell grid 'E' coords
    sp = findShortestPath grid end Set.empty (Heap.fromList [(0, (start, "r"))])

findShortestPath grid target visited queue
  | not $ isInBounds grid (r,c) = findShortestPath grid target nvisited squeue
  | cell == '#'                 = findShortestPath grid target nvisited squeue
  | Set.member (r,c) visited    = findShortestPath grid target nvisited squeue
  | (r,c) == (tr,tc)            = dist
  | otherwise                   = findShortestPath grid target nvisited nqueue
  where
    (top, squeue) = case Heap.viewMin queue of
      Just (top, squeue) -> (top, squeue)
      Nothing            -> error "Heap is empty!"
    (dist, ((r,c), dir)) = top
    nvisited = Set.insert (r,c) visited
    cell = ((grid!!r)!!c)
    (tr, tc) = target
    (up, right, down, left) = ((r-1,c),(r,c+1),(r+1,c),(r,c-1))
    cost = costForDir dir
    (upCost, rightCost, downCost, leftCost) = (cost "u", cost "r", cost "d", cost "l")
    nqueue = 
      Heap.insert (dist+upCost, (up, "u"))
      $ Heap.insert (dist+rightCost, (right, "r"))
      $ Heap.insert (dist+downCost, (down, "d"))
      $ Heap.insert (dist+leftCost, (left, "l"))
      $ squeue

costForDir idir tdir 
  | idir == tdir = 1
  | idir == "u" && tdir == "d" = 2001
  | idir == "d" && tdir == "u" = 2001
  | idir == "l" && tdir == "r" = 2001
  | idir == "r" && tdir == "l" = 2001
  | otherwise                  = 1001

findCell _ _ [] = error "cell not found"
findCell grid tcell ((r,c):coords) =
  if ((grid!!r)!!c) == tcell then (r,c) else findCell grid tcell coords

allCoords grid = [(r,c) | r <- [0..(length grid)-1], c <- [0..(length $ head grid)-1]]

isInBounds grid (r,c) = r >= 0 && r < (length grid) && c >= 0 && c < (length $ head grid)

import qualified Data.Map as Map
import Data.Map (Map)
import Data.Heap (Heap)
import qualified Data.Heap as Heap
import qualified Data.Set as Set
import Data.Set (Set)
import Data.List (nub)
import Debug.Trace

max_dist = maxBound :: Int

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = 
  length paths
  where
    grid = lines input
    coords = allCoords grid
    start = findCell grid 'S' coords
    end = findCell grid 'E' coords
    visited = findShortestPath grid end Map.empty Map.empty max_dist (Heap.fromList [(0, (start, start, "r"))])
    predecessors = Set.fromList $ findPredecessors Set.empty visited start end
    lowestScore = findLowestScore grid end Set.empty (Heap.fromList [(0, (start, "r"))])
    paths = findAllShortestPaths lowestScore predecessors Set.empty 0 (Set.insert start Set.empty) end start "r"

findAllShortestPaths lowestScore predecessors visited dist path target (r,c) dir
  | not $ Set.member (r,c) predecessors = Set.empty
  | Set.member (r,c) visited            = Set.empty
  | (r,c) == target                     = if dist == lowestScore then path else Set.empty
  | otherwise                           = nextSteps
  where
    nvisited = Set.insert (r,c) visited
    cost = costForDir dir
    nextSteps = 
      Set.unions
      $ map (\(ncoord, ndist, ndir) -> 
        findAllShortestPaths lowestScore predecessors nvisited (dist+ndist) (Set.insert ncoord path) target ncoord ndir)
      $ [
          ((r-1,c), cost "u", "u"),
          ((r,c+1), cost "r", "r"),
          ((r+1,c), cost "d", "d"),
          ((r,c-1), cost "l", "l")
        ]

findPredecessors vpredecessors visited start end 
  | end == start = [start]
  | Set.member end vpredecessors = []
  | otherwise    = end:nresult
  where
    (_, _, predecessors) = visited Map.! end
    nvpredecessors = Set.insert end vpredecessors
    nresult = concat $ map (findPredecessors nvpredecessors visited start) predecessors

findShortestPath grid target visited successors maxdist queue
  | Heap.null queue             = visited
  | dist > maxdist              = findShortestPath grid target visited successors maxdist squeue
  | not $ isInBounds grid (r,c) = findShortestPath grid target visited successors maxdist squeue
  | cell == '#'                 = findShortestPath grid target visited successors maxdist squeue
  | Map.member (r,c) visited    = findShortestPath grid target updatedVisited successors maxdist squeue
  | (r,c) == (tr,tc)            = findShortestPath grid target nvisited nsuccessors (min maxdist dist) squeue
  | otherwise                   = findShortestPath grid target nvisited nsuccessors maxdist nqueue
  where
    (top, squeue) = case Heap.viewMin queue of
      Just (top, squeue) -> (top, squeue)
      Nothing            -> error "Heap is empty!"
    (dist, ((r,c), prev, dir)) = top
    nvisited = Map.insert (r,c) (dir, dist, [prev]) visited
    nsuccessors = Map.insert prev (r,c) successors
    cell = ((grid!!r)!!c)
    (tr, tc) = target
    (up, right, down, left) = ((r-1,c),(r,c+1),(r+1,c),(r,c-1))
    cost = costForDir dir
    (upCost, rightCost, downCost, leftCost) = (cost "u", cost "r", cost "d", cost "l")
    nqueue = 
      Heap.insert (dist+upCost, (up, (r,c), "u"))
      $ Heap.insert (dist+rightCost, (right, (r,c), "r"))
      $ Heap.insert (dist+downCost, (down, (r,c), "d"))
      $ Heap.insert (dist+leftCost, (left, (r,c), "l"))
      $ squeue
    (vdir, vdist, vpredecessors) = visited Map.! (r,c)
    (sr, sc) = if Map.member (r,c) successors then successors Map.! (r,c) else (-1,-1)
    successorCost = if Map.member (sr,sc) visited 
                       then 
                         let (sdir, sdist, _) = visited Map.! (sr, sc)
                          in (costForDir vdir sdir) - 1
                        else 0
    fdist = vdist+1000
    updatedVisited = 
      if dist <= fdist then Map.insert (r,c) (vdir, vdist, prev:vpredecessors) visited else visited

findLowestScore grid target visited queue
  | not $ isInBounds grid (r,c) = findLowestScore grid target nvisited squeue
  | cell == '#'                 = findLowestScore grid target nvisited squeue
  | Set.member (r,c) visited    = findLowestScore grid target nvisited squeue
  | (r,c) == (tr,tc)            = dist
  | otherwise                   = findLowestScore grid target nvisited nqueue
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

costForDir :: String -> String -> Int
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

printGrid grid paths [] = ""
printGrid grid paths (pos:poss) = result ++ nresult
  where
    (r,c) = pos
    cell = ((grid!!r)!!c)
    isEndCol = c == (length $ head grid) - 1
    nl = if isEndCol then "\n" else ""
    result = if (r,c) `elem` paths then "O" ++ nl else [cell] ++ nl
    nresult = printGrid grid paths poss


import qualified Data.Set as Set
import Data.List

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = sum $ zipWith (*) allAreas allPerimeters
  where
    matrix = lines input
    poss = allPositions matrix
    allAreas = areas matrix Set.empty poss
    allPerimeters = perimeters matrix Set.empty poss

areas _ _ [] = []
areas matrix visited ((r,c):poss) = carea:nareas
  where
    (carea, nvisited) = 
      area matrix visited (r,c) ((matrix!!r)!!c)
    nareas = areas matrix nvisited poss

area matrix visited (r,c) symbol 
  | not $ isInBounds matrix (r,c) = (0, visited)
  | Set.member (r,c) visited      = (0, visited)
  | ((matrix!!r)!!c) == symbol    = (1 + nresult, nvisited)
  | otherwise                     = (0, visited)
  where
    cvisited = Set.insert (r,c) visited
    (resUp, visitedUp) = 
      area matrix (Set.insert (r,c) visited) (r-1,c) symbol
    (resRight, visitedRight) = 
      area matrix (Set.insert (r,c) visitedUp) (r,c+1) symbol
    (resDown, visitedDown) = 
      area matrix (Set.insert (r,c) visitedRight) (r+1,c) symbol
    (resLeft, visitedLeft) = 
      area matrix (Set.insert (r,c) visitedDown) (r,c-1) symbol
    nresult = resUp + resRight + resDown + resLeft
    nvisited = Set.insert (r,c) visitedLeft

perimeters _ _ [] = []
perimeters matrix visited ((r,c):poss) = (length sides):nperimeters
  where
    (cperimeter, nvisited) = 
      perimeter matrix visited (r,c) ((matrix!!r)!!c) ""
    sides = groupSides [] (toSides cperimeter)
    nperimeters = perimeters matrix nvisited poss

toSides perimeterCells = sort $ nub $ perimeterCells

groupSides :: [[(String, Int, Int)]] -> [(String, Int, Int)] -> [[(String, Int, Int)]]
groupSides groups [] = groups
groupSides groups ((dir,r,c):sides)
  | Just matchingGroup <- maybeGroup =
      let updatedGroups = replaceGroup groups matchingGroup ((dir, r, c) : matchingGroup)
      in groupSides updatedGroups sides
  | otherwise = groupSides (groups ++ [[(dir,r,c)]]) sides
  where
    maybeGroup = find (\group -> any (\(adir, ar, ac) -> (adir == dir) && ((abs (ar-r)) + (abs (ac-c)) <= 1)) group) groups

replaceGroup :: Eq a => [[a]] -> [a] -> [a] -> [[a]]
replaceGroup groups oldGroup newGroup = 
  map (\group -> if group == oldGroup then newGroup else group) groups

perimeter matrix visited (r,c) symbol dir
  | not $ isInBounds matrix (r,c) = ([(dir, r,c)], visited)
  | ((matrix!!r)!!c) /= symbol    = ([(dir,r,c)], visited)
  | Set.member (r,c) visited      = ([], visited)
  | otherwise                     = (nresult, nvisited)
  where
    cvisited = Set.insert (r,c) visited
    (resUp, visitedUp) = 
      perimeter matrix (Set.insert (r,c) visited) (r-1,c) symbol "up"
    (resRight, visitedRight) = 
      perimeter matrix (Set.insert (r,c) visitedUp) (r,c+1) symbol "right"
    (resDown, visitedDown) = 
      perimeter matrix (Set.insert (r,c) visitedRight) (r+1,c) symbol "down"
    (resLeft, visitedLeft) = 
      perimeter matrix (Set.insert (r,c) visitedDown) (r,c-1) symbol "left"
    nresult = resUp ++ resRight ++ resDown ++ resLeft
    nvisited = Set.insert (r,c) visitedLeft

allPositions matrix = 
  [(x, y) | 
    x <- [0..(length matrix - 1)], 
    y <- [0..(length (matrix !! 0) - 1)]]

isInBounds matrix (r,c) = 
  r >= 0 && r < length matrix && c >= 0 && c < length (matrix !! 0)

import Debug.Trace
import Data.List.Split (splitOn)
import Data.List (sort, delete, intersect, nub)
import qualified Data.Text as Text

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = 
  sum $ map (\[(r,c),_] -> 100*r+c) fboxes
  where
    [matrixStr, dirsStr] = splitOn "\n\n" $ trimWhitespace input
    matrix = transformMatrix $ splitOn "\n" matrixStr
    dirs = filter (/= '\n') dirsStr
    allPos = allPositions matrix
    spos = findStartPos matrix allPos
    boxes = findBoxes matrix allPos
    (fpos, fboxes) = moveDirs matrix spos boxes dirs

moveDirs _ spos boxes [] = (spos, boxes)
moveDirs matrix spos boxes (dir:dirs) = trace dbglog $ moveDirs matrix npos nboxes dirs
  where
    nboxes = moveAndPushBoxes matrix spos boxes dir
    npos = moveStartPos matrix spos nboxes dir
    allPos = allPositions matrix
    na = (sum $ map (\[(r0,c0),(r1,c1)] -> r0+r1+c0+c1) nboxes) `div` 100000000
    dbglog = "steps left: " ++ (show ((length dirs)-na))

moveStartPos matrix spos boxes dir
  = if isValidMove then (nr,nc) else spos
  where
    (nr, nc) = moveElem spos dir
    isValidMove = ((matrix!!nr)!!nc) /= '#' && (not $ elem (nr,nc) $ concat boxes)

moveAndPushBoxes matrix spos boxes dir = pushed
  where
    nboxes = moveBoxes matrix spos boxes boxes dir
    notMoved = nub $ intersect nboxes boxes
    moved = excludeWithDuplicates nboxes notMoved
    pushed = pushAllBoxes notMoved moved dir

moveBoxes _ _ [] _ _ = []
moveBoxes matrix spos (box:boxes) allBoxes dir
  = nbox:nres
  where
    (nr0, nc0) = moveElem (box!!0) dir
    (nr1, nc1) = moveElem (box!!1) dir
    shouldMove = shouldMoveBox box spos dir
    edges = findAllImpactedEdges allBoxes dir box
    isValidMoveForPoint (r,c) = anyEmptySpaces matrix (r,c) allBoxes dir
    isValidMove = all (==True) $ map isValidMoveForPoint edges
    nbox = if shouldMove && isValidMove 
              then [(nr0,nc0),(nr1,nc1)] else box
    nres = moveBoxes matrix spos boxes allBoxes dir

findAllImpactedEdges :: [[(Int, Int)]] -> Char -> [(Int, Int)] -> [(Int, Int)]
findAllImpactedEdges boxes dir boxToMove
  | null impactedBoxes = boxToMove
  | otherwise          = boxToMove ++ (concat $ map (findAllImpactedEdges boxes dir) impactedBoxes)
  where
    (nr0, nc0) = moveElem (boxToMove!!0) dir
    (nr1, nc1) = moveElem (boxToMove!!1) dir
    pointsInBox p0 p1 b = (p0 `elem` b) || (p1 `elem` b)
    boxesWithoutBox = filter (/= boxToMove) boxes
    impactedBoxes = filter (pointsInBox (nr0,nc0) (nr1, nc1)) boxesWithoutBox

anyEmptySpaces matrix (nr, nc) boxes dir
  = (length emptySpaces) > 0
  where
    allposs = allPositions matrix
    poss = takePositionsInDir matrix (nr,nc) dir
    isEmptySpace (r,c) = 
      ((matrix!!r)!!c) /= '#' && (not $ elem (r,c) $ concat boxes)
    emptySpaces = 
      filter isEmptySpace 
      $ takeWhile (\(r,c) -> ((matrix!!r)!!c) /= '#') poss
    dbglog = "pos: " ++ (show (nr,nc)) ++ " es: " ++ (show emptySpaces)

takePositionsInDir matrix (r,c) dir
  | cell == '#' = []
  | otherwise   = (r,c):takePositionsInDir matrix npos dir
  where
    cell = ((matrix!!r)!!c)
    npos
      | dir == '^' = (r-1,c)
      | dir == 'v' = (r+1,c)
      | dir == '>' = (r,c+1)
      | dir == '<' = (r,c-1)
      | otherwise  = error "invalid dir"

pushAllBoxes :: [[(Int, Int)]] -> [[(Int, Int)]] -> Char -> [[(Int, Int)]]
pushAllBoxes boxes moved dir
  | nboxes == boxes = (boxes ++ moved) 
  | otherwise       = pushAllBoxes notPushed (pushed++moved) dir
  where
    nboxes = pushBoxes boxes moved dir
    notPushed = nub $ intersect nboxes boxes
    pushed = excludeWithDuplicates nboxes notPushed

-- Remove elements in list2 from list1, accounting for duplicates
excludeWithDuplicates :: Eq a => [a] -> [a] -> [a]
excludeWithDuplicates [] _ = []
excludeWithDuplicates list1 [] = list1
excludeWithDuplicates (x:xs) list2
    | x `elem` list2 = excludeWithDuplicates xs (delete x list2) -- Remove one occurrence of x from both lists
    | otherwise = x : excludeWithDuplicates xs list2

pushBoxes :: [[(Int, Int)]] -> [[(Int, Int)]] -> Char -> [[(Int, Int)]]
pushBoxes [] _ _ = []
pushBoxes (box:boxes) moved dir
  | elem (r0,c0) cmoved = nbox:nres
  | elem (r1,c1) cmoved = nbox:nres
  | otherwise           = box:nres
  where
    [(r0,c0),(r1,c1)] = box
    cmoved = concat moved
    (nr0, nc0) = moveElem (r0,c0) dir
    (nr1, nc1) = moveElem (r1,c1) dir
    nbox = [(nr0,nc0),(nr1,nc1)]
    nres = pushBoxes boxes moved dir

shouldMoveBox box spos dir = (box!!0) == npos || (box!!1) == npos
  where
    npos = moveElem spos dir

moveElem (r,c) dir
  | dir == '^' = (r-1, c) 
  | dir == '>' = (r, c+1)
  | dir == 'v' = (r+1, c)
  | dir == '<' = (r, c-1)
  | otherwise  = error "invalid dir"

findBoxes _ [] = []
findBoxes matrix ((r,c):ps) 
  | ((matrix!!r)!!c) == '[' = [(r,c), (r,c+1)]:(findBoxes matrix ps)
  | otherwise               = findBoxes matrix ps

findStartPos _ [] = (-1,-1)
findStartPos matrix ((r,c):ps) 
  | ((matrix!!r)!!c) == '@' = (r,c)
  | otherwise               = findStartPos matrix ps

allPositions xss = 
  [(r, c) | 
    r <- [0..(length xss - 1)], 
    c <- [0..(length (head xss) - 1)]]

trimWhitespace = Text.unpack . Text.strip . Text.pack

transformMatrix matrix = map (concat . transformMatrixRow) matrix

transformMatrixRow row = map mapFunc row
  where
    mapFunc cell 
      | cell == 'O' = "[]"
      | cell == '@' = "@."
      | cell == '#' = "##"
      | otherwise   = ".."

printState _ _ _ [] = ""
printState matrix spos boxes ((r,c):poss)
  | any (elem (r,c)) $ map init boxes = "[" ++ sep ++ next
  | any (elem (r,c)) $ map tail boxes = "]" ++ sep ++ next
  | (r,c) == spos                     = "@" ++ sep ++ next
  | ((matrix!!r)!!c) == '#'           = "#" ++ sep ++ next
  | otherwise                         = "." ++ sep ++ next
  where 
    next = printState matrix spos boxes poss
    sep = if (length (head matrix)) - 1 == c then "\n" else ""

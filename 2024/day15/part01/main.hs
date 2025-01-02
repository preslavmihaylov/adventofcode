import Debug.Trace
import Data.List.Split (splitOn)
import Data.List (sort)
import qualified Data.Text as Text

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = sum $ map (\(r,c) -> 100*r+c) fboxes
  where
    [matrixStr, dirsStr] = splitOn "\n\n" $ trimWhitespace input
    matrix = splitOn "\n" matrixStr
    dirs = filter (/= '\n') dirsStr
    allPos = allPositions matrix
    spos = findStartPos matrix allPos
    boxes = findBoxes matrix allPos
    (fpos, fboxes) = moveDirs matrix spos boxes dirs

moveDirs _ spos boxes [] = (spos, boxes)
moveDirs matrix spos boxes (dir:dirs) = moveDirs matrix npos nboxes dirs
  where
    nboxes = moveAndPushBoxes matrix spos boxes dir
    npos = moveStartPos matrix spos nboxes dir
    allPos = allPositions matrix
    currState = 
      (printState matrix spos boxes allPos) ++ 
        (show (spos, boxes)) ++ "\n" ++
        (show dir) ++ "\n"

moveStartPos matrix spos boxes dir
  = if isValidMove then (nr,nc) else spos
  where
    (nr, nc) = moveElem spos dir
    isValidMove = ((matrix!!nr)!!nc) /= '#' && (not $ elem (nr,nc) boxes)

moveAndPushBoxes matrix spos boxes dir = pushed
  where
    moved = moveBoxes matrix spos boxes boxes dir
    pushed = pushAllBoxes moved dir

moveBoxes _ _ [] _ _ = []
moveBoxes matrix spos (box:boxes) allBoxes dir
  = nbox:nres
  where
    (nr, nc) = moveElem box dir
    shouldMove = shouldMoveBox box spos dir
    isValidMove = anyEmptySpaces matrix (nr,nc) allBoxes dir
    nbox = if shouldMove && isValidMove 
              then (nr,nc) else box
    nres = moveBoxes matrix spos boxes allBoxes dir

anyEmptySpaces matrix (nr, nc) boxes dir
  = (length emptySpaces) > 0
  where
    allposs = allPositions matrix
    poss = takePositionsInDir matrix (nr,nc) dir
    isEmptySpace (r,c) = 
      ((matrix!!r)!!c) /= '#' && (not $ elem (r,c) boxes)
    emptySpaces = 
      filter isEmptySpace 
      $ takeWhile (\(r,c) -> ((matrix!!r)!!c) /= '#') poss

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

pushAllBoxes boxes dir
  = if pushed == boxes then boxes else pushAllBoxes pushed dir
  where
    pushed = pushBoxes boxes dir

pushBoxes [] _ = []
pushBoxes (box:boxes) dir
  = if elem box boxes then (nr,nc):nres else box:nres
  where
    (nr, nc) = moveElem box dir
    nres = pushBoxes boxes dir

shouldMoveBox box spos dir = box == npos
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
  | ((matrix!!r)!!c) == 'O' = (r,c):(findBoxes matrix ps)
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

printState _ _ _ [] = ""
printState matrix spos boxes ((r,c):poss)
  | elem (r,c) boxes        = "O" ++ sep ++ next
  | (r,c) == spos           = "@" ++ sep ++ next
  | ((matrix!!r)!!c) == '#' = "#" ++ sep ++ next
  | otherwise               = "." ++ sep ++ next
  where 
    next = printState matrix spos boxes poss
    sep = if (length (head matrix)) - 1 == c then "\n" else ""

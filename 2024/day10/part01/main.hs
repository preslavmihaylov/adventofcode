import Debug.Trace
import Data.Char (ord)
import Data.List (nub)

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = fres
  where
    matrix = lines input
    dests = findDestinations matrix (allPositions matrix)
    results = concat [countRoutes matrix (-1, -1) (r ,c) (r, c) | (r, c) <- dests]
    fres = length $ nub $ filter (\x -> (snd x) /= (-1, -1)) results

countRoutes matrix ppos cpos orig
  | (not isGradualSlope) || (not inBounds) = [(orig, (-1, -1))]
  | currVal == 0 = [(orig, cpos)]
  | otherwise = cnt
  where
    prevVal = (ord (charAt matrix ppos)) - (ord '0')
    currVal = (ord (charAt matrix cpos)) - (ord '0')
    isGradualSlope = (isSentinel ppos) || prevVal - currVal == 1
    inBounds = isInBounds matrix cpos
    (up, right, down, left) = ((-1, 0), (0, 1), (1, 0), (0, -1))
    cnt = 
      countRoutes matrix cpos (addt cpos up) orig ++
      countRoutes matrix cpos (addt cpos right) orig ++
      countRoutes matrix cpos (addt cpos down) orig ++
      countRoutes matrix cpos (addt cpos left) orig

addt (a1, b1) (a2, b2) = (a1+a2, b1+b2)

charAt matrix (r, c) = 
  if isSentinel (r, c) || (not (isInBounds matrix (r, c))) 
     then '0' 
     else ((matrix!!r)!!c)

isSentinel (r ,c) = r == -1 && c == -1

findDestinations :: [String] -> [(Int, Int)] -> [(Int, Int)]
findDestinations matrix [] = []
findDestinations matrix ((r, c):poss) = 
  if pos == '9' then (r, c):dests else dests
  where
    pos = charAt matrix (r, c)
    dests = (findDestinations matrix poss)

allPositions xss = 
  [(r, c) | 
    r <- [0..(length xss - 1)], 
    c <- [0..(length (head xss) - 1)]]
    
isInBounds matrix (row, col) = row >= 0 && row < (length matrix) && col >= 0 && col < (length (head matrix))

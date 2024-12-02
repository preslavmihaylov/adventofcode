main = do
  input <- readFile "../input.txt"
  print $ solve $ mapInput input

solve = length . filter isSafeReport
-- alternative:
-- solve xss = sum [1 | xs <- xss, isSafeReport xs]

isSafeReport xs = 
  (isAllIncreasing xs || isAllDecreasing xs) && maxDiff xs <= 3

isAllIncreasing (x:[]) = True
isAllIncreasing (x:xs) = 
  x < (xs!!0) && isAllIncreasing xs

isAllDecreasing xs = 
  all (uncurry (>)) (zip xs (tail xs))

maxDiff (x:[]) = 0
maxDiff (x:xs) =
  max (abs $ x - (xs!!0)) (maxDiff xs)

mapInput input = allLevels
  where 
    tokens = let splitLine line = [x | x <- (words line)]
             in map splitLine (lines input)
    allLevels = 
      let asInts vals = map read vals :: [Int]
      in map asInts tokens


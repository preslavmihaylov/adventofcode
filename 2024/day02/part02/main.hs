import Data.List (delete)

main = do
  input <- readFile "../input.txt"
  print $ solve $ mapInput input

solve xss = length [xs | xs <- xss, anySafeReport $ allReportVariants xs]

allReportVariants xs = 
  [take i xs ++ drop (i + 1) xs | i <- [0 .. length xs - 1]]

anySafeReport xss = (length [1 | xs <- xss, isSafeReport xs]) > 0

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


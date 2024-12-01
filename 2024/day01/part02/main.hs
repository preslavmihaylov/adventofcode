main = do
  input <- readFile "../input.txt"
  print $ solve $ mapInput input

solve arrs = sum $ map (\x -> x * (totalOccurrences rightArr x)) leftArr
  where
    leftArr = fst arrs
    rightArr = snd arrs

totalOccurrences elements el = sum [1 | x <- elements, x == el]

mapInput input = (leftArr, rightArr)
  where 
    tokens = map splitLine $ lines input
    leftArr = [read (x !! 0) :: Int | x <- tokens]
    rightArr = [read (x !! 1) :: Int | x <- tokens]


splitLine line = [x | x <- (split ' ' line), x /= ""]

split :: Eq a => a -> [a] -> [[a]]
split d [] = []
split d s = x : split d (drop 1 y) where (x,y) = span (/= d) s


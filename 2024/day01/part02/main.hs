main = do
  input <- readFile "../input.txt"
  print $ solve $ mapInput input

solve (leftArr, rightArr) = 
  sum $ map (\x -> x * (totalOccurrences rightArr x)) leftArr

totalOccurrences elements el = sum [1 | x <- elements, x == el]

mapInput input = (leftArr, rightArr)
  where 
    splitLine line = [x | x <- (split ' ' line), x /= ""]
    tokens = map splitLine $ lines input
    asInts vals = (read (vals!!0) :: Int, read (vals!!1) :: Int)
    (leftArr, rightArr) = unzip $ map asInts tokens

split :: Eq a => a -> [a] -> [[a]]
split d [] = []
split d s = x : split d (drop 1 y) where (x,y) = span (/= d) s


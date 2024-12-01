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
    splitLine line = [x | x <- (split ' ' line), x /= ""]
    tokens = map splitLine $ lines input
    (leftArr, rightArr) = unzip $ map (\x -> (read (x !! 0) :: Int, read (x !! 1) :: Int)) tokens

split :: Eq a => a -> [a] -> [[a]]
split d [] = []
split d s = x : split d (drop 1 y) where (x,y) = span (/= d) s


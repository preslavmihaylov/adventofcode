import Data.List (sort)

main = do
  input <- readFile "../input.txt"
  print $ solve $ mapInput input

solve arrs = calcDistance (leftArr, rightArr)
  where
    leftArr = sort $ fst arrs
    rightArr = sort $ snd arrs

calcDistance arrs = if null leftArr then 0 else currDist + calcDistance (tail leftArr, tail rightArr)
  where
    leftArr = fst arrs
    rightArr = snd arrs
    currDist = abs ((head leftArr) - (head rightArr))

mapInput input = (leftArr, rightArr)
  where 
    ls = lines input
    tokens = map splitLine ls
    leftArr = [read (x !! 0) :: Int | x <- tokens]
    rightArr = [read (x !! 1) :: Int | x <- tokens]


splitLine line = [x | x <- (split ' ' line), x /= ""]

split :: Eq a => a -> [a] -> [[a]]
split d [] = []
split d s = x : split d (drop 1 y) where (x,y) = span (/= d) s


import Data.List

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = length $ blinkNTimes nums 25
  where
    nums = map (\n -> read n :: Integer) $ words input

blinkNTimes nums n
  | n > 0     = blinkNTimes blinked (n-1)
  | otherwise = nums
  where blinked = blink nums

blink [] = []
blink (num:nums)
  | num == 0         = 1:nresult
  | isEvenDigits num = [left, right] ++ nresult
  | otherwise        = (num*2024):nresult
  where
    nresult = blink nums
    (left, right) = splitNumber num

splitNumber n =
  let digits = show n 
      len = length digits               
      half = len `div` 2                 
      (left, right) = splitAt half digits 
  in (read left, read right)             


isEvenDigits num = (length (show num)) `mod` 2 == 0


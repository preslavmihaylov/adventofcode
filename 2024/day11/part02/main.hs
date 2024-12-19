import Debug.Trace
import Data.List
import qualified Data.Map as Map

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = sum $ map snd $ Map.toList $ blinkNTimes (listToMap nums) 75
  where
    nums = map (\n -> read n :: Int) $ words input

blinkNTimes :: Map.Map Int Int -> Int -> Map.Map Int Int
blinkNTimes numsMap n =
  if n > 0 then blinkNTimes nresult (n-1) else numsMap
  where
    nresult = blink numsMap

blink :: Map.Map Int Int -> Map.Map Int Int
blink nums = blink2 (Map.toList nums)

blink2 :: [(Int, Int)] -> Map.Map Int Int
blink2 [] = Map.empty
blink2 ((k,v):nums) = Map.unionWith (+) cresult nresult
  where
    cresultList = nextNums k v
    cresult = Map.unionsWith (+) $ map (uncurry Map.singleton) cresultList
    nresult = blink2 nums

listToMap :: [Int] -> Map.Map Int Int
listToMap [] = Map.empty
listToMap (n:ns) = Map.unionWith (+) (Map.singleton n 1) (listToMap ns)

nextNums num times
  | num == 0 = [(1, times)]
  | isEvenDigits num = [(left, times), (right, times)]
  | otherwise = [(num*2024, times)]
  where
    (left, right) = splitNumber num

splitNumber n =
  let digits = show n 
      len = length digits               
      half = len `div` 2                 
      (left, right) = splitAt half digits 
  in (read left, read right)             


isEvenDigits num = (length (show num)) `mod` 2 == 0


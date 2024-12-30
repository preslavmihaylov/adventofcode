import Data.List.Split (splitOn)
import Data.Bits (xor)

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve :: String -> Integer
solve input = sum $ map (genNextSecrets 2000) $ nums
  where
    nums = map read $ lines input

genNextSecrets 0 secret = secret
genNextSecrets n secret = genNextSecrets (n-1) (genNextSecret secret)

genNextSecret secret = step3
  where
    nmod = 16777216
    step1 = ((secret * 64) `xor` secret) `mod` nmod
    step2 = ((step1 `div` 32) `xor` step1) `mod` nmod
    step3 = ((step2 * 2048) `xor` step2) `mod` nmod

import Data.List.Split
import Data.List
import Data.Bits

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = findRegA 0 (reverse instrs)
  where
    [regStrs, instrStrs] = splitOn "\n\n" input
    instrs = parseInstrs instrStrs

findRegA prevBits [] = prevBits
findRegA prevBits (t:targets)
  | length matches > 0 = findRegA nPrevBits targets
  | otherwise          = (-1)
  where
    potentialMatches = 
      filter (\v -> equationMatches v prevBits t) [0..7]
    matchWorksFunc m = 
      (findRegA nPrevBits targets) /= (-1)
      where
        nPrevBits = (prevBits `shiftL` 3) .|. m
    matches = filter matchWorksFunc potentialMatches
    [match] = take 1 matches
    nPrevBits = (prevBits `shiftL` 3) .|. match

-- this func only works for my input as it's a decoded formula
-- based on the given program.
-- You will need to adapt it to your input before using it.
equationMatches :: Int -> Int -> Int -> Bool
equationMatches bits prevBits target = 
  eqResult == target
  where
    num = (prevBits `shiftL` 3) .|. bits
    nmod = (num `mod` 8)
    eqResult = ((nmod `xor` 6) `xor` (num `div` (2^(nmod `xor` 3)))) `mod` 8

parseInstrs instrStr = 
  map (\v -> read v :: Int) $ splitOn "," $ ((splitOn ": " instrStr)!!1)


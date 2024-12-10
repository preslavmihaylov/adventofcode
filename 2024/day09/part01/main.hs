import qualified Data.Text as T
import Data.Char (digitToInt)

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve inp = calcChecksum 0 $ defrag [] uncompressedInput
  where 
    input = trimWhitespace inp
    ns = [digitToInt str | str <- input]
    uncompressedInput = uncompress ns 0 True

calcChecksum :: Integer -> [Integer] -> Integer
calcChecksum idx [] = 0
calcChecksum idx (n:ns) = (idx*n) + (calcChecksum (idx+1) ns)

defrag prev [] = prev
defrag prev nums
  | fstElem /= -1 = defrag (prev ++ [fstElem]) (tail nums)
  | lstElem == -1 = defrag prev (init nums)
  | otherwise     = defrag (prev ++ [lstElem]) (init (tail nums))
  where
    fstElem = head nums
    lstElem = last nums

defrag prev [] = prev
defrag prev nums
  | fstElem /= -1 = defrag (prev ++ [fstElem]) (tail nums)
  | lstElem == -1 = defrag prev (init nums)
  | otherwise     = defrag (prev ++ [lstElem]) (init (tail nums))
  where
    fstElem = head nums
    lstElem = last nums

uncompress [] _ _ = []
uncompress (n:ns) idx isFile = r ++ (uncompress ns nextIdx (not isFile))
  where 
    numToReplicate = if isFile then idx else -1
    nextIdx = if isFile then idx else idx+1
    r = replicate n numToReplicate

trimWhitespace = T.unpack . T.strip . T.pack

printAsStr :: [Int] -> String
printAsStr = concatMap replace
  where
    replace (-1) = "."   -- Replace -1 with "."
    replace n    = show n  -- Convert other numbers to strings

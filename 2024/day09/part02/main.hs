import Debug.Trace
import qualified Data.Text as T
import Data.Char (digitToInt)

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve inp = calcChecksum 0 $ defragAll [] uncompressedInput []
  where 
    input = trimWhitespace inp
    nums = [digitToInt str | str <- input]
    uncompressedInput = uncompress nums 0 True

calcChecksum idx [] = 0
calcChecksum idx (n:ns) = (idx*fileId) + (calcChecksum (idx+1) ns)
  where
    fileId = if n == -1 then 0 else n

defragAll defragLeft frag defragRight 
  | cf == frag = defragLeft ++ frag ++ defragRight
  | otherwise  = defragAll (defragLeft ++ cdl) cf (cdr ++ defragRight)
  where
    (cdl, cf, cdr) = defrag frag []

defrag [] skipped = ([], [], skipped)
defrag nums skipped
  | fileId == -1     = defrag numsExceptFile (file ++ skipped)
  | newFileLoc /= -1 = (defraggedLeftBlock, leftOfFile ++ file ++ rightOfFile, emptiedFile ++ skipped)
  | otherwise        = defrag numsExceptFile (file ++ skipped)
  where
    rnums = reverse nums
    fileId = last nums
    file = takeWhile (== fileId) rnums
    emptiedFile = replicate (length file) (-1)
    numsExceptFile = reverse $ dropWhile (== fileId) rnums
    newFileLoc = findEmptySpot nums 0 (length file)
    defraggedLeftBlock = takeWhile (/= (-1)) nums
    leftOfFile = drop (length defraggedLeftBlock) (take newFileLoc nums)
    rightOfFile = drop (newFileLoc + (length file)) numsExceptFile

findEmptySpot [] i len = -1
findEmptySpot (x:xs) i len 
  | x /= -1 = findEmptySpot xs (i+1) len
  | otherwise = 
    if curr == expected
      then i else findEmptySpot xs (i+1) len
  where
    curr = x:(take (len-1) xs)
    expected = replicate len (-1)

uncompress [] _ _ = []
uncompress (n:ns) idx isFile = r ++ (uncompress ns nextIdx (not isFile))
  where 
    numToReplicate = if isFile then idx else -1
    nextIdx = if isFile then idx else idx+1
    r = replicate n numToReplicate

trimWhitespace = T.unpack . T.strip . T.pack

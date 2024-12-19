import qualified Data.Map as Map
import Data.List.Split (splitOn)
import Data.List (isPrefixOf)
import Debug.Trace

input_file = "../input.txt"

main = do
  input <- readFile input_file
  print $ solve input

solve input = 
  sumAllArrangements Map.empty towels spatterns
  where
    [towelsStr, spatternsStr] = splitOn "\n\n" input
    towels = splitOn ", " towelsStr
    spatterns = filter (/="") $ splitOn "\n" spatternsStr

sumAllArrangements _ _ [] = 0
sumAllArrangements cache towels (ptrn:patterns) =
  result + sumAllArrangements ncache towels patterns
  where
    (ncache, result) = genArrangements cache towels ptrn

genArrangements cache _ "" = (cache, 1)
genArrangements cache towels pattern
  | Map.member pattern cache = (cache, cache Map.! pattern)
  | otherwise = (ncache, result)
  where
    possibleMatches = [
      drop (length t) pattern | t <- towels, t `isPrefixOf` pattern]
    arrangements = aggregateArrangements cache towels possibleMatches
    result = snd arrangements
    ncache = Map.insert pattern result $ fst arrangements

aggregateArrangements cache _ [] = (cache, 0)
aggregateArrangements cache towels (ptrn:patterns)
  = (Map.unions [ncache,fcache], nresult+fresult)
  where
    (ncache, nresult) = genArrangements cache towels ptrn
    (fcache, fresult) = aggregateArrangements ncache towels patterns

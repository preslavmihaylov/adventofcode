import Data.Char (isDigit)
import Data.List (groupBy, sortBy, uncons)
import Data.Map qualified as Map
import Data.Maybe (mapMaybe)
import Data.Ord (comparing)
import Data.Set qualified as Set

numpad_start_pos = (3, 2)

numpad_invalid_pos = (3, 0)

keypad_invalid_pos = (0, 0)

robots_cnt = 25

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = result
  where
    codes = lines input
    paths = map pathForCode codes
    complexities = map complexityForCode codes
    result = sum $ map (\(p, c) -> p * c) $ zip paths complexities

complexityForCode :: String -> Int
complexityForCode code = read $ takeWhile isDigit code

pathForCode :: String -> Int
pathForCode code = snd $ processPaths Map.empty robots_cnt $ pathsForNumpadCode code

processPaths :: Map.Map String Int -> Int -> [String] -> (Map.Map String Int, Int)
processPaths cache depth [] = (cache, maxBound :: Int)
processPaths cache depth (p : paths) = (ncache, min curr next)
  where
    pathToProcess = if depth /= 0 then ('A' : p) else p
    cacheKey = show (pathToProcess, depth)
    (cache1, curr) = case Map.lookup cacheKey cache of
      Just v -> (cache, v)
      Nothing -> processPath cache depth pathToProcess
    cache2 = Map.insert cacheKey curr cache1
    (ncache, next) = processPaths cache2 depth paths

processPath :: Map.Map String Int -> Int -> String -> (Map.Map String Int, Int)
processPath cache 0 path = (cache, length path)
processPath cache depth path = (ncache, sum minPaths)
  where
    pairs = toPairs path
    paths = map processPair $ pairs
    (finalCache, results) = foldl processPath' (cache, []) paths
    processPath' (c, acc) p =
      let (newCache, result) = processPaths c (depth - 1) p
       in (newCache, result : acc)
    minPaths = reverse results
    ncache = finalCache

processPair (s, e) = allPaths keypad_invalid_pos loc1 loc2
  where
    loc1 = head $ keypadCodeToPos [s]
    loc2 = head $ keypadCodeToPos [e]

toPairs :: String -> [(Char, Char)]
toPairs str = zip str (tail str)

pathsForNumpadCode code = pathsForLocs numpad_invalid_pos (numpad_start_pos : locs)
  where
    locs = numpadCodeToPos code

pathsForLocs _ [loc] = [""]
pathsForLocs invalidPos (loc : locs) = result
  where
    dest = case uncons locs of
      Just (dest, _) -> dest
      Nothing -> error "invalid arr"
    paths = allPaths invalidPos loc dest
    npaths = pathsForLocs invalidPos locs
    result = [a ++ b | a <- paths, b <- npaths]

allPaths invalidPos from to
  | from == invalidPos = [['I']] -- going through this position is invalid
  | from == to = [['A']]
  | otherwise = filter (\ds -> not $ 'I' `elem` ds) $ concat [up, down, left, right]
  where
    (r0, c0) = from
    (r1, c1) = to
    up = if r1 < r0 then map (\ds -> '^' : ds) (allPaths invalidPos (r0 - 1, c0) (r1, c1)) else []
    down = if r1 > r0 then map (\ds -> 'v' : ds) (allPaths invalidPos (r0 + 1, c0) (r1, c1)) else []
    left = if c1 < c0 then map (\ds -> '<' : ds) (allPaths invalidPos (r0, c0 - 1) (r1, c1)) else []
    right = if c1 > c0 then map (\ds -> '>' : ds) (allPaths invalidPos (r0, c0 + 1) (r1, c1)) else []

numpadCodeToPos :: String -> [(Int, Int)]
numpadCodeToPos [] = []
numpadCodeToPos (c : cs)
  | c == '7' = (0, 0) : numpadCodeToPos cs
  | c == '8' = (0, 1) : numpadCodeToPos cs
  | c == '9' = (0, 2) : numpadCodeToPos cs
  | c == '4' = (1, 0) : numpadCodeToPos cs
  | c == '5' = (1, 1) : numpadCodeToPos cs
  | c == '6' = (1, 2) : numpadCodeToPos cs
  | c == '1' = (2, 0) : numpadCodeToPos cs
  | c == '2' = (2, 1) : numpadCodeToPos cs
  | c == '3' = (2, 2) : numpadCodeToPos cs
  | c == '0' = (3, 1) : numpadCodeToPos cs
  | c == 'A' = (3, 2) : numpadCodeToPos cs
  | otherwise = error "invalid code"

keypadCodeToPos :: String -> [(Int, Int)]
keypadCodeToPos [] = []
keypadCodeToPos (c : cs)
  | c == '^' = (0, 1) : keypadCodeToPos cs
  | c == 'A' = (0, 2) : keypadCodeToPos cs
  | c == '<' = (1, 0) : keypadCodeToPos cs
  | c == 'v' = (1, 1) : keypadCodeToPos cs
  | c == '>' = (1, 2) : keypadCodeToPos cs
  | otherwise = error "invalid code"

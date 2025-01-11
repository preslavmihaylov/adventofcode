import Data.Char (isDigit)
import Data.List (sortBy, uncons)
import Data.Maybe (mapMaybe)
import Data.Ord (comparing)
import Debug.Trace

numpad_start_pos = (3, 2)

numpad_invalid_pos = (3, 0)

keypad_start_pos = (0, 2)

keypad_invalid_pos = (0, 0)

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = result
  where
    codes = lines input
    paths = map pathForCode codes
    complexities = map complexityForCode codes
    lengths = map length $ mapMaybe safeHead paths
      where
        safeHead (x : _) = Just x
        safeHead [] = Nothing
    result = sum $ map (\(l, c) -> l * c) $ zip lengths complexities

complexityForCode :: String -> Int
complexityForCode code = read $ takeWhile isDigit code

pathForCode code = sortBy (comparing length) human
  where
    robot1 = pathsForNumpadCode code
    robot2 = concat $ map pathsForKeypadCode robot1
    human = concat $ map pathsForKeypadCode robot2

pathsForNumpadCode code = pathsForLocs numpad_invalid_pos (numpad_start_pos : locs)
  where
    locs = numpadCodeToPos code

pathsForKeypadCode code = pathsForLocs keypad_invalid_pos (keypad_start_pos : locs)
  where
    locs = keypadCodeToPos code

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

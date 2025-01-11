import Data.List.Split

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = length validCombos
  where
    schematics = map lines $ splitOn "\n\n" input
    locks = map asPins $ filter isLock schematics
    keys = map asPins $ filter (not . isLock) schematics
    validCombos = [cs | lock <- locks, key <- keys, let cs = zipWith (+) key lock, all (<= 5) cs]

asPins schematic
  | isLock schematic = [countCols exclFstRow (0, col) | col <- [0 .. 4]]
  | otherwise = [countCols exclLstRow (0, col) | col <- [0 .. 4]]
  where
    exclFstRow = tail schematic
    exclLstRow = init schematic

countCols matrix (row, col)
  | row >= length matrix = 0
  | otherwise = cnt + countCols matrix (row + 1, col)
  where
    cnt = if ((matrix !! row) !! col) == '#' then 1 else 0

printSchematic s = unlines s

isLock s = (s !! 0) == "#####"

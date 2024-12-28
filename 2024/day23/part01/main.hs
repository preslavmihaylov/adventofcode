import Data.List.Split (splitOn)
import Data.List ((\\), sort, nub)
import Data.Map (Map)
import qualified Data.Map as Map
import qualified Data.Set as Set
import Debug.Trace

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = length $ findAllLoops conns (Map.keys conns)
  where conns = parseInput input

findAllLoops conns [] = []
findAllLoops conns (key:keys) = Set.toList $ Set.fromList $ loops ++ nloops
  where
    loops = find3ElemLoop conns key
    nloops = findAllLoops conns keys

find3ElemLoop conns key = 
  nub $ 
  map sort $ 
  map init $ 
  filter (\loop -> (length loop) == 4 && startsWithChar 't' loop) $
  map (\loop -> dropWhile (/= (last loop)) loop) $
  findLoops conns Set.empty key 0

findLoops :: Map String [String] -> Set.Set String -> String -> Int -> [[String]]
findLoops conns visited key clen
  | clen == 3          = [[key]]
  | Set.member key visited = [[key]]
  | otherwise          = filter (\l -> (length l) <= 4) loops
  where
    nvisited = Set.insert key visited
    loops = map (key:) $ concatMap (\e -> findLoops conns nvisited e (clen+1)) $ conns Map.! key

parseInput input = combineToMap $ map parseConn $ lines input

combineToMap :: (Ord k) => [[(k, k)]] -> Map.Map k [k]
combineToMap lists = foldl insertPair Map.empty (concat lists)
  where
    insertPair acc (k, v) = Map.insertWith (++) k [v] acc

parseConn connStr = Map.toList $ Map.insert from to (Map.insert to from Map.empty)
  where
    [from, to] = splitOn "-" connStr

startsWithChar :: Char -> [String] -> Bool
startsWithChar c strs = any (\s -> not (null s) && head s == c) strs

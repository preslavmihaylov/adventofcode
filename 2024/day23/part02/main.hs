import Data.List.Split (splitOn)
import Data.List ((\\), sort, nub, intersect, sortBy, intercalate)
import Data.Map (Map)
import qualified Data.Map as Map
import qualified Data.Set as Set
import Debug.Trace

main = do
  input <- readFile "../input.txt"
  putStrLn $ solve input

solve input = result
  where 
    conns = parseInput input
    vals = map sort $ map (\(k,v) -> k:v) $ Map.toList conns
    result = 
      (intercalate ",") . sort . head 
      $ filter (\lst -> all (connectedToNodes conns lst) lst) 
      $ nub . sortListsByLength 
      $ [intersect l1 l2 | l1 <- vals, l2 <- vals, l1 /= l2]

connectedToNodes conns nodes key = all (`elem` (key:edges)) nodes
  where
    edges = conns Map.! key

sortListsByLength :: [[a]] -> [[a]]
sortListsByLength = sortBy (\x y -> compare (length y) (length x))

parseInput input = combineToMap $ map parseConn $ lines input

combineToMap :: (Ord k) => [[(k, k)]] -> Map.Map k [k]
combineToMap lists = foldl insertPair Map.empty (concat lists)
  where
    insertPair acc (k, v) = Map.insertWith (++) k [v] acc

parseConn connStr = Map.toList $ Map.insert from to (Map.insert to from Map.empty)
  where
    [from, to] = splitOn "-" connStr

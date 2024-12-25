import Data.List.Split
import Data.List (isPrefixOf, sort)
import Data.Map (Map)
import qualified Data.Map as Map

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = result
  where
    [constsStr, gatesStr] = splitOn "\n\n" input
    consts = map parseConst $ lines constsStr
    logicGates = map parseLogicGate $ lines gatesStr
    gates = Map.union (Map.fromList logicGates) (Map.fromList consts)
    result = 
      binaryToInt . concat . reverse
      $ map (evalGate gates) 
      $ sort . (map fst)
      $ filter (\(l, _) -> "z" `isPrefixOf` l) logicGates

evalGate gates label = if res then "1" else "0"
  where
    gate = gates Map.! label
    res = evalAny gate gates

binaryToInt :: String -> Int
binaryToInt = foldl (\acc x -> acc * 2 + (if x == '1' then 1 else 0)) 0

parseConst line = (label, AnyGate $ ConstGate boolVal)
  where
    [label, val] = splitOn ": " line
    boolVal = val == "1"

parseLogicGate line = (label, AnyGate $ LogicGate g1 g2 operator)
  where
    [gatesStr, label] = splitOn " -> " line
    [g1, operator, g2] = words gatesStr

class Show g => Gate g where
  eval :: g -> Map String AnyGate -> Bool

data AnyGate = forall g. Gate g => AnyGate g

instance Show AnyGate where
  show (AnyGate g) = show g

evalAny :: AnyGate -> Map String AnyGate -> Bool
evalAny (AnyGate g) mp = eval g mp

data ConstGate = ConstGate { value :: Bool }
data LogicGate = LogicGate { gate1 :: String, gate2 :: String, operator :: String }

instance Gate ConstGate where
  eval cg gates = value cg

instance Show ConstGate where
  show (ConstGate v) = "ConstGate " ++ show v

instance Gate LogicGate where
  eval lg gates = r
    where
      r1 = case Map.lookup (gate1 lg) gates of
             Just g1 -> evalAny g1 gates
             Nothing -> error $ "Gate not found: " ++ gate1 lg
      r2 = case Map.lookup (gate2 lg) gates of
             Just g2 -> evalAny g2 gates
             Nothing -> error $ "Gate not found: " ++ gate2 lg
      r | operator lg == "AND" = r1 && r2
        | operator lg == "OR"  = r1 || r2
        | operator lg == "XOR" = r1 /= r2
        | otherwise            = error $ "invalid operator" ++ (operator lg)

instance Show LogicGate where
  show (LogicGate g1 g2 op) = "LogicGate " ++ show g1 ++ " " ++ show g2 ++ " " ++ show op

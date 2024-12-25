import Data.List.Split
import Debug.Trace
import Data.List (isPrefixOf, sort, intercalate)
import Data.Map (Map)
import Text.Printf
import qualified Data.Map as Map

-- I figured these out by looking at the generated dot graph and finding
-- the gates that are swapped
swapped_wires = ["z20", "hhh", "z15", "htp", "z05", "dkr", "rhv", "ggk"]

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = 
  -- uncomment this to see the generated dot graph for hand-solving...
  -- generateDotGraph logicGates
  
  -- uncomment this to validate if x + y == z
  -- isCorrectResult logicGates consts gates
  
  -- actual answer
  intercalate "," $ sort swapped_wires
  where
    [constsStr, gatesStr] = splitOn "\n\n" input
    consts = map parseConst $ lines constsStr
    logicGates = map parseLogicGate $ lines gatesStr
    logicGatesAsAny = map (\(l, lg) -> (l, logicGateAsAnyGate lg)) logicGates
    gates = Map.union (Map.fromList logicGatesAsAny) (Map.fromList consts)

generateDotGraph logicGates = graph
  where
    graph = intercalate "\n" $ map 
      (\(l, lg) -> 
        printf "%s [label=\"%s\" shape=rect style=dashed]\n %s -> %s\n%s -> %s\n%s -> %s" 
          (l ++ (operator lg)) (operator lg)
          (gate1 lg) (l ++ (operator lg))
          (gate2 lg) (l ++ (operator lg))
          (l ++ (operator lg)) l) logicGates

isCorrectResult logicGates consts gates = 
  trace (show (x,y,z)) $ x + y == z
  where
    x = evalNumber "x" consts gates
    y = evalNumber "y" consts gates
    z = evalNumber "z" logicGates gates

evalNumber label logicGates gates = result
  where
    result = 
      binaryToInt . concat . reverse
      $ map (evalGate gates) 
      $ sort . (map fst)
      $ filter (\(l, _) -> label `isPrefixOf` l) logicGates
  

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

logicGateAsAnyGate :: LogicGate -> AnyGate
logicGateAsAnyGate lg = AnyGate lg

parseLogicGate line = (label, LogicGate g1 g2 operator)
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

import Data.List.Split
import Debug.Trace

main = do
  input <- readFile "../input.txt"
  print 
    $ sum  -- sum [target1, target2, ...]
    $ map fst -- map [(target, vals)] -> [target]
    $ filter isPossibleEquation 
    $ map mapRow (lines input) -- input -> [(target, vals)]

isPossibleEquation (target, vals) = any (\v -> v == target) eqs
  where
    eqs = evalEquations target vals

evalEquations _ (val:[]) = [val]
evalEquations limit vals = sumEqs ++ mulEqs ++ concatEqs
  where
    lastVal = last vals
    prevs = init vals
    sumEqs = [next + lastVal | next <- (evalEquations limit prevs), next <= limit]
    mulEqs = [next * lastVal | next <- (evalEquations limit prevs), next <= limit]
    concatEqs = 
      [concatNums next lastVal | next <- (evalEquations limit prevs), next <= limit]

concatNums x y = x * (10 ^ numDigits y) + y
  where numDigits n = length (show n)

mapRow row = (target, vals)
  where 
    tokens = splitOn ":" row
    target = read (tokens!!0) :: Integer
    vals = map (\v -> read v :: Integer) (words (tokens!!1))

import Data.List.Split

main = do
  input <- readFile "../input.txt"
  print 
    $ sum  -- sum [target1, target2, ...]
    $ map fst -- map [(target, vals)] -> [target]
    $ filter isPossibleEquation 
    $ map mapRow (lines input) -- input -> [(target, vals)]

isPossibleEquation (target, vals) = any (\v -> v == target) eqs
  where
    eqs = evalEquations vals

evalEquations (val:[]) = [val]
evalEquations vals = sumEqs ++ mulEqs
  where
    lastVal = last vals
    prevs = init vals
    sumEqs = [lastVal + next | next <- (evalEquations prevs)]
    mulEqs = [lastVal * next | next <- (evalEquations prevs)]

mapRow row = (target, vals)
  where 
    tokens = splitOn ":" row
    target = read (tokens!!0) :: Integer
    vals = map (\v -> read v :: Integer) (words (tokens!!1))

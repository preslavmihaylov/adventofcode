import Data.List.Split (splitOn)
import Data.List (isPrefixOf)

input_file = "../input.txt"

main = do
  input <- readFile input_file
  print $ solve input

solve input = 
  length [
    ptrn | ptrn <- spatterns, canBeArranged towels ptrn
  ]
  where
    [towelsStr, spatternsStr] = splitOn "\n\n" input
    towels = splitOn ", " towelsStr
    spatterns = filter (/="") $ splitOn "\n" spatternsStr

canBeArranged _ "" = True
canBeArranged towels pattern =
  any (canBeArranged towels) 
    [drop (length t) pattern | t <- towels, t `isPrefixOf` pattern]

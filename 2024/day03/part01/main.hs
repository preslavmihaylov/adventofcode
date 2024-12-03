import Text.Regex.Posix

main = do
  input <- readFile "../input.txt"
  print $ solve $ trimWhitespaces $ input

solve "" = 0
solve str = a*b + solve (drop len str)
  where
    (a, b, len) = extractInstr str

extractInstr str = 
  if length patternMatch > 0 
     then (read (matches!!1)::Int, read (matches!!2)::Int, matchLen) 
     else (0,0,1)
  where 
    pattern = "^mul\\(([0-9]+),([0-9]+)\\)"
    patternMatch = str =~ pattern::[[String]]
    matchLen = length ((patternMatch!!0)!!0)
    matches = (patternMatch)!!0

trimWhitespaces = filter (/= '\n')

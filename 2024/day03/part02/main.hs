import Text.Regex.Posix

main = do
  input <- readFile "../input.txt"
  print $ solve (trimWhitespaces input) True

solve "" _ = 0
solve str isEnabled = 
  if isEnabled 
     then a*b + solve (drop len str) nextIsEnabled 
     else solve (drop 1 str) nextIsEnabled
  where
    (a, b, len) = extractMulInstr str
    nextIsEnabled
      | isDoInstr str   = True
      | isDontInstr str = False
      | otherwise       = isEnabled

isDoInstr str = str =~ "^do\\(\\)"::Bool
isDontInstr str = str =~ "^don't\\(\\)"::Bool

extractMulInstr str =
  case str =~ "^mul\\(([0-9]+),([0-9]+)\\)" :: [[String]] of
    (match:_) -> (read (match!!1), read (match!!2), length (match!!0))
    _         -> (0, 0, 1)

trimWhitespaces = filter (/= '\n')

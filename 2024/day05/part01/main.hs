import Data.List.Split (splitOn)

main = do
  input <- readFile "../input.txt"
  let (rules, updateRows) = mapInput input
   in print $ sum $ map getMiddlePage $ allValidRows rules updateRows

getMiddlePage pages = pages !! (len `div` 2)
  where len = fromIntegral (length pages)

allValidRows rules updateRows = [r | r <- updateRows, isValidUpdate rules [] r]

isValidUpdate :: [(Int, Int)] -> [Int] -> [Int] -> Bool
isValidUpdate rules prevPages (page:nextPages) = 
  (length invalidPrevPages) == 0 && isValidNextUpdate
  where
    matchingRules = filter (\(left, _) -> left == page) rules
    invalidPrevPages = [pp | pp <- prevPages, any (\(_, right) -> right == pp) matchingRules]
    isValidNextUpdate = 
      if length nextPages == 0 then True else
        isValidUpdate rules (page:prevPages) nextPages

mapInput input = (rules, updateRows)
  where
    (rulesStr, updateRowsStr) = break null (lines input)
    rules = [parseRule ruleStr | ruleStr <- rulesStr]
    updateRows = [parseUpdateRow row | row <- updateRowsStr, row /= ""]

parseRule :: String -> (Int, Int)
parseRule ruleStr = (read a, read b)
  where
    [a, b] = splitOn "|" ruleStr

parseUpdateRow :: String -> [Int]
parseUpdateRow rowStr = [read str | str <- strs]
  where
    strs = splitOn "," rowStr

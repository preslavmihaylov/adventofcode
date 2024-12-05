import Data.List.Split (splitOn)
import Debug.Trace (trace)

main = do
  input <- readFile "../input.txt"
  let (rules, updateRows) = mapInput input
   in print $ sum $ map getMiddlePage $ map (\row -> fixInvalidRow rules row) $ allInvalidRows rules updateRows

getMiddlePage pages = pages !! (len `div` 2)
  where len = fromIntegral (length pages)

fixInvalidRow rules row = 
  if row == currentFix then row else fixInvalidRow rules currentFix
  where
    currentFix = (fixInvalidElement rules [] row)

fixInvalidElement rules prevPages (page:nextPages) = 
  if null putAfter then nextFix
     else putBefore ++ [page] ++ putAfter ++ nextPages
  where
    matchingRules = filter (\(left, _) -> left == page) rules
    violatesAnyRule = (\page -> any (\(_, right) -> right == page) matchingRules)
    (putBefore, putAfter) = break violatesAnyRule prevPages
    nextFix | null nextPages = prevPages ++ [page] ++ nextPages
            | otherwise      = fixInvalidElement rules (prevPages ++ [page]) nextPages

allInvalidRows rules updateRows = [r | r <- updateRows, not $ isValidUpdate rules [] r]

isValidUpdate :: [(Int, Int)] -> [Int] -> [Int] -> Bool
isValidUpdate rules prevPages (page:nextPages) = 
  null invalidPrevPages && isValidNextUpdate
  where
    matchingRules = filter (\(left, _) -> left == page) rules
    invalidPrevPages = [pp | pp <- prevPages, any (\(_, right) -> right == pp) matchingRules]
    isValidNextUpdate = 
      if length nextPages == 0 then True else
        isValidUpdate rules (prevPages ++ [page]) nextPages

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

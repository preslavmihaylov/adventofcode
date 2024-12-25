import Data.List.Split
import Debug.Trace
import Text.Printf

data Button = Button{ 
  xOffset :: Int, 
  yOffset :: Int 
} deriving (Show, Eq)

data Prize = Prize{ 
  x :: Int, 
  y :: Int 
} deriving (Show, Eq)

data Machine = Machine{ 
  buttonA :: Button, 
  buttonB :: Button, 
  prize :: Prize 
} deriving (Show, Eq)

main = do
  input <- readFile "../input.txt"
  putStrLn $ solve input

solve :: String -> String
solve input = printf "%.0f" result
  where
    result = sum $ map calcMinPrizeCost $ map parseMachine $ splitOn "\n\n" input

calcMinPrizeCost :: Machine -> Double
calcMinPrizeCost machine = 
  if noSolutionFound then 0 else xPress*3 + yPress*1
  where
    prz = prize machine
    btnA = buttonA machine
    btnAX = xOffset btnA
    btnAY = yOffset btnA
    btnB = buttonB machine
    btnBX = xOffset btnB
    btnBY = yOffset btnB
    prizeX = x prz
    prizeY = y prz

    -- cramers rule - https://www.youtube.com/watch?v=vXqlIOX2itM
    d = btnAX * btnBY - btnBX * btnAY
    dx = prizeX * btnBY - prizeY * btnBX
    dy = prizeX * btnAY - prizeY * btnAX
    xPress = abs $ (fromIntegral dx) / (fromIntegral d)
    yPress = abs $ (fromIntegral dy) / (fromIntegral d)
    noSolutionFound = (not $ isInt xPress) || (not $ isInt yPress)

parseMachine :: String -> Machine
parseMachine machineStr = Machine buttonA buttonB prize
  where
    splitted = filter (/= "") $ splitOn "\n" machineStr
    [buttonAStr, buttonBStr, prizeStr] = splitted
    buttonA = parseButton buttonAStr
    buttonB = parseButton buttonBStr
    prize = parsePrize prizeStr

parseButton :: String -> Button
parseButton buttonStr = Button x y
  where
    [xStr, yStr] = splitOn ", " $ (splitOn ": " buttonStr) !! 1
    x = read $ drop 2 xStr
    y = read $ drop 2 yStr

parsePrize :: String -> Prize
parsePrize prizeStr = Prize x y
  where
    [xStr, yStr] = splitOn ", " $ (splitOn ": " prizeStr) !! 1
    x = (read $ drop 2 xStr) + 10000000000000
    y = (read $ drop 2 yStr) + 10000000000000

isInt x = x == fromInteger (round x)

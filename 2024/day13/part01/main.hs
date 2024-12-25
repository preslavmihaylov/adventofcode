import Data.List.Split

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
  print $ solve input

solve input = result
  where
    result = sum $ map calcMinPrizeCost $ map parseMachine $ splitOn "\n\n" input

calcMinPrizeCost :: Machine -> Int
calcMinPrizeCost machine = 
  if length possibleCosts == 0 then 0 else minPrizeCost
  where
    prz = prize machine
    btnA = buttonA machine
    btnAX = xOffset btnA
    btnAY = yOffset btnA
    btnB = buttonB machine
    btnBX = xOffset btnB
    btnBY = yOffset btnB
    prizeXY = (x prz, y prz)
    possibleCosts = [btnAPress * 3 + btnBPress * 1
      | btnAPress <- [0..100], btnBPress <- [0..100], 
      (btnAX * btnAPress + btnBX * btnBPress, 
       btnAY * btnAPress + btnBY * btnBPress) == prizeXY]
    minPrizeCost = minimum possibleCosts

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
    x = read $ drop 2 xStr
    y = read $ drop 2 yStr

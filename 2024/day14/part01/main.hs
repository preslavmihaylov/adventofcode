import Data.List.Split

data Robot = Robot{ 
  x :: Int, 
  y :: Int,
  vx :: Int,
  vy :: Int
} deriving (Show, Eq)

-- example input grid size
-- grid_rows = 7
-- grid_cols = 11

-- real input grid size
grid_rows = 103
grid_cols = 101

main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = foldl1 (*) $ groupByQuadrantCnt result
  where
    robots = map parseRobot $ lines input
    result = map (moveRobot 100) robots

moveRobot 0 robot = robot
moveRobot times robot = 
  moveRobot (times-1) nrobot
  where
    nx = wrapAround ((x robot) + (vx robot)) grid_cols
    ny = wrapAround ((y robot) + (vy robot)) grid_rows
    nrobot = Robot nx ny (vx robot) (vy robot)

wrapAround :: Int -> Int -> Int
wrapAround n maxSize = (n `mod` maxSize + maxSize) `mod` maxSize

parseRobot :: String -> Robot
parseRobot line = Robot x y vx vy
  where
    [posStr, velStr] = map (\v -> drop 2 v) $ splitOn " " line
    [x,y] = map read $ splitOn "," posStr
    [vx,vy] = map read $ splitOn "," velStr

groupByQuadrantCnt :: [Robot] -> [Int]
groupByQuadrantCnt robots = 
  [length q1, length q2, length q3, length q4]
  where
    midCols = grid_cols `div` 2
    midRows = grid_rows `div` 2
    q1 = filter (\r -> (x r) < midCols && (y r) < midRows) robots
    q2 = filter (\r -> (x r) > midCols && (y r) < midRows) robots
    q3 = filter (\r -> (x r) < midCols && (y r) > midRows) robots
    q4 = filter (\r -> (x r) > midCols && (y r) > midRows) robots


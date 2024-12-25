import Data.List.Split
import Debug.Trace

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

total_steps = 10000

-- run the program with ./main 2> log.txt and search for "###############"
main = do
  input <- readFile "../input.txt"
  print $ solve input

solve input = result
  where
    robots = map parseRobot $ lines input
    result = moveRobots total_steps robots

moveRobots 0 robots = robots
moveRobots times robots = trace (printGrid (total_steps-times+1) nrobots) $ moveRobots (times-1) nrobots
  where
    nrobots = map (moveRobot 1) robots

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

printGrid step robots = "step " ++ (show step) ++ "\n" ++ grid ++ "\n\n"
  where
    robotCoords = map (\(Robot x y _ _) -> (x, y)) robots
    allPositions = [(x, y) | y <- [0 .. grid_rows - 1], x <- [0 .. grid_cols - 1]]
    mapFunc (x,y) = if (x,y) `elem` robotCoords then ("#" ++ nl) else ("." ++ nl)
      where
        nl = if x == grid_cols - 1 then "\n" else ""
    grid = concat $ map mapFunc allPositions

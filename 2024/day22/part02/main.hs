import Data.List.Split (splitOn)
import Data.List (sortOn)
import qualified Data.Map as Map
import qualified Data.Set as Set
import Data.Bits (xor)
import Data.Ord (Down(..))

main = do
  input <- readFile "../input.txt"
  print $ solve input

times = 2000

solve input = result
  where
    nums = map (\v -> read v :: Integer) $ lines input
    allPrices = 
      map (map secretToPrice) 
      $ map (genNextSecrets times) 
      $ nums
    allChanges = map genPriceChanges allPrices
    changeSeqs = 
      concat 
      $ map (\(cs,ps) -> genPriceChangeSequence Set.empty cs ps) 
      $ zip allChanges allPrices
    result = 
      snd . head . sortOn (Down . snd) 
      $ Map.toList $ Map.fromListWith (+) changeSeqs

genPriceChangeSequence visited (c:cs) (p:ps)
  | Set.member seq visited = nresult
  | length cs < 3          = []
  | otherwise              = (seq, price):nresult
  where
    others = take 3 cs
    price = head $ drop 3 ps
    seq = c:others
    nvisited = Set.insert seq visited
    nresult = genPriceChangeSequence nvisited cs ps

genPriceChanges ps = reverse $ genPriceChanges' (reverse ps)

genPriceChanges' (p:[]) = []
genPriceChanges' (p:ps) = (p-np):(genPriceChanges' ps)
  where
    np = head ps

secretToPrice secret = secret `mod` 10

genNextSecrets 0 secret = [secret]
genNextSecrets n secret = secret:(genNextSecrets (n-1) (genNextSecret secret))

genNextSecret secret = step3
  where
    nmod = 16777216
    step1 = ((secret * 64) `xor` secret) `mod` nmod
    step2 = ((step1 `div` 32) `xor` step1) `mod` nmod
    step3 = ((step2 * 2048) `xor` step2) `mod` nmod

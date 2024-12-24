import Data.List.Split
import Data.List
import Data.Bits
import Debug.Trace

main = do
  input <- readFile "../input.txt"
  putStrLn $ solve input

solve input = execProgram (regA, regB, regC) instrs 0 ""
  where
    [regStrs, instrStrs] = splitOn "\n\n" input
    [regA, regB, regC] = parseRegs regStrs
    instrs = parseInstrs instrStrs

execProgram regs instrs instrPtr output = 
  if instrPtr >= length instrs 
     then formatOutput output
  else execProgram nregs instrs nInstrPtr (output ++ nOutput)
  where
    (nregs, nInstrPtr, nOutput) =
      execInstr regs instrs instrPtr

execInstr regs instrs instrPtr = 
  if length nextInstr < 2
    then (regs, instrPtr, "")
    else result
  where
    nextInstr = take 2 $ drop instrPtr instrs
    [opcode, operand] = nextInstr
    result = execOpcode regs instrPtr operand opcode

execOpcode :: (Int, Int, Int) -> Int -> Int -> Int -> ((Int, Int, Int), Int, [Char])
execOpcode (regA, regB, regC) instrPtr operand opcode
  | opcode == 0 = r0
  | opcode == 1 = r1
  | opcode == 2 = r2
  | opcode == 3 = r3
  | opcode == 4 = r4
  | opcode == 5 = r5
  | opcode == 6 = r6
  | opcode == 7 = r7
  where
    r0 = execADV (regA, regB, regC) instrPtr operand
    r1 = execBXL (regA, regB, regC) instrPtr operand
    r2 = execBST (regA, regB, regC) instrPtr operand
    r3 = execJNZ (regA, regB, regC) instrPtr operand
    r4 = execBXC (regA, regB, regC) instrPtr operand
    r5 = execOUT (regA, regB, regC) instrPtr operand
    r6 = execBDV (regA, regB, regC) instrPtr operand
    r7 = execCDV (regA, regB, regC) instrPtr operand

execADV (regA, regB, regC) instrPtr operand = 
  (
    (
      regA `div` (2^(combo (regA, regB, regC) operand)), 
      regB, 
      regC
    ),
    instrPtr+2,
    ""
  )

execBXL (regA, regB, regC) instrPtr operand = 
  (
    (
      regA,
      regB `xor` operand,
      regC
    ),
    instrPtr+2,
    ""
  )

execBST (regA, regB, regC) instrPtr operand = 
  (
    (
      regA,
      (combo (regA, regB, regC) operand) `mod` 8,
      regC
    ),
    instrPtr+2,
    ""
  )

execJNZ (regA, regB, regC) instrPtr operand = 
  (
    (
      regA,
      regB,
      regC
    ),
    if regA == 0 then instrPtr+2 else operand,
    ""
  )

execBXC (regA, regB, regC) instrPtr operand = 
  (
    (
      regA,
      regB `xor` regC,
      regC
    ),
    instrPtr+2,
    ""
  )

execOUT (regA, regB, regC) instrPtr operand = 
  (
    (
      regA,
      regB,
      regC
    ),
    instrPtr+2,
    "" ++ (show $ (combo (regA, regB, regC) operand) `mod` 8)
  )

execBDV (regA, regB, regC) instrPtr operand = 
  (
    (
      regA, 
      regA `div` (2^(combo (regA, regB, regC) operand)), 
      regC
    ),
    instrPtr+2,
    ""
  )

execCDV (regA, regB, regC) instrPtr operand = 
  (
    (
      regA, 
      regB,
      regA `div` (2^(combo (regA, regB, regC) operand))
    ),
    instrPtr+2,
    ""
  )

combo (regA, regB, regC) operand
  | operand <= 3 = operand
  | operand == 4 = regA
  | operand == 5 = regB
  | operand == 6 = regC
  | otherwise    = error "invalid program"

parseRegs regStr = map parseReg $ lines regStr
  where parseReg = (\v -> read ((splitOn ": " v) !! 1) :: Int) 

parseInstrs instrStr = 
  map (\v -> read v :: Int) $ splitOn "," $ ((splitOn ": " instrStr)!!1)

formatOutput s = concat $ intersperse "," $ map (:[]) s


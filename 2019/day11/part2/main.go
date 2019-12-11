package main

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

const maxArguments = 3

// OpCode ...
type OpCode int64

// opcodes
const (
	OpAdd           OpCode = 1
	OpMultiply             = 2
	OpInput                = 3
	OpOutput               = 4
	OpJumpIfTrue           = 5
	OpJumpIfFalse          = 6
	OpLessThan             = 7
	OpEquals               = 8
	OpRelBaseOffset        = 9
	OpHalt                 = 99
)

// PosMode ...
type PosMode int64

// pos modes
const (
	PosModeAddress  PosMode = 0
	PosModeValue            = 1
	PosModeRelative         = 2
)

func newCommand(inst int64) *command {
	cmd := command{}
	cmd.opcode = OpCode(inst % 100)
	inst /= 100

	for i := 0; i < maxArguments; i++ {
		cmd.posModes = append(cmd.posModes, PosMode(inst%10))
		inst /= 10
	}

	return &cmd
}

type command struct {
	opcode   OpCode
	posModes []PosMode
}

func (c *command) instructionSize() int64 {
	if c.opcode == OpInput || c.opcode == OpOutput || c.opcode == OpRelBaseOffset {
		return 2
	} else if c.opcode == OpJumpIfTrue || c.opcode == OpJumpIfFalse {
		return 3
	}

	return 4
}

type program struct {
	instructions []int64
	memory       map[int64]int64
	instPtr      int64
	relativeBase int64
}

func main() {
	prog := &program{instructions: make([]int64, len(initProgram)), memory: make(map[int64]int64), instPtr: 0, relativeBase: 0}
	copy(prog.instructions, initProgram)

	run(prog, inputCallback, outputCallback)
	showPainting()
}

func showPainting() {
	// find dimensions of grid
	smallestRow, smallestCol := math.MaxInt32, math.MaxInt32
	biggestRow, biggestCol := math.MinInt32, math.MinInt32
	for key := range paintedCells {
		coords := strings.Split(key, "+")
		row, err := strconv.Atoi(coords[0])
		if err != nil {
			panic(err)
		}

		col, err := strconv.Atoi(coords[1])
		if err != nil {
			panic(err)
		}

		if smallestRow > row {
			smallestRow = row
		}

		if biggestRow < row {
			biggestRow = row
		}

		if smallestCol > col {
			smallestCol = col
		}

		if biggestCol < col {
			biggestCol = col
		}
	}

	grid := make([][]int64, biggestRow-smallestRow+1)
	for row := 0; row < len(grid); row++ {
		grid[row] = make([]int64, biggestCol-smallestCol+1)
	}

	// fill grid with colors
	for key, color := range paintedCells {
		coords := strings.Split(key, "+")
		row, err := strconv.Atoi(coords[0])
		if err != nil {
			panic(err)
		}

		col, err := strconv.Atoi(coords[1])
		if err != nil {
			panic(err)
		}

		grid[row-smallestRow][col-smallestCol] = color
	}

	// print resulting painting
	for row := 0; row < len(grid); row++ {
		for col := 0; col < len(grid[row]); col++ {
			if grid[row][col] == 0 {
				fmt.Print(" ")
			} else {
				fmt.Print("*")
			}
		}

		fmt.Println()
	}
}

// Point ...
type Point struct {
	row, col int64
}

// RobotState ...
type RobotState int64

// ...
const (
	RobotStateIdle   RobotState = 0
	RobotStateMoving            = 1
)

// Direction ...
type Direction int64

// ...
const (
	DirectionRight   Direction = 0
	DirectionDown    Direction = 1
	DirectionLeft    Direction = 2
	DirectionForward Direction = 3
	DirectionsCnt    Direction = 4
)

var currentLoc = Point{5000, 5000}
var paintedCells = map[string]int64{
	fmt.Sprintf("%d+%d", currentLoc.row, currentLoc.col): 1,
}
var state = RobotStateIdle
var direction = DirectionForward

func inputCallback() int64 {
	hash := fmt.Sprintf("%d+%d", currentLoc.row, currentLoc.col)

	return paintedCells[hash]
}

func outputCallback(val int64) {
	hash := fmt.Sprintf("%d+%d", currentLoc.row, currentLoc.col)
	if state == RobotStateIdle {
		paintedCells[hash] = val
		state = RobotStateMoving
	} else {
		// left
		if val == 0 {
			direction = direction - 1
			if direction < 0 {
				direction = DirectionForward
			}
		} else {
			direction = (direction + 1) % DirectionsCnt
		}

		switch direction {
		case DirectionForward:
			currentLoc.row--
		case DirectionRight:
			currentLoc.col++
		case DirectionDown:
			currentLoc.row++
		case DirectionLeft:
			currentLoc.col--
		}

		state = RobotStateIdle
	}
}

func run(prog *program, inputCb func() int64, outputCb func(int64)) {
	inputIndex := 0
	if prog.instPtr != 0 {
		inputIndex = 1
	}

	for {
		cmd := newCommand(prog.instructions[prog.instPtr])

		didJump := false
		switch cmd.opcode {
		case OpAdd:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := getAddr(prog, prog.instructions[prog.instPtr+3], cmd.posModes[2])

			writeAddr(prog, outputAddr, in1+in2)
		case OpMultiply:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := getAddr(prog, prog.instructions[prog.instPtr+3], cmd.posModes[2])

			writeAddr(prog, outputAddr, in1*in2)
		case OpInput:
			val := inputCb()
			inputIndex++

			outputAddr := getAddr(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			writeAddr(prog, outputAddr, val)
		case OpOutput:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])

			outputCb(in1)
		case OpJumpIfTrue:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog, prog.instructions[prog.instPtr+2], cmd.posModes[1])

			if in1 != 0 {
				didJump = true
				prog.instPtr = in2
			}
		case OpJumpIfFalse:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog, prog.instructions[prog.instPtr+2], cmd.posModes[1])

			if in1 == 0 {
				didJump = true
				prog.instPtr = in2
			}
		case OpLessThan:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := getAddr(prog, prog.instructions[prog.instPtr+3], cmd.posModes[2])

			if in1 < in2 {
				writeAddr(prog, outputAddr, 1)
			} else {
				writeAddr(prog, outputAddr, 0)
			}
		case OpEquals:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := getAddr(prog, prog.instructions[prog.instPtr+3], cmd.posModes[2])

			if in1 == in2 {
				writeAddr(prog, outputAddr, 1)
			} else {
				writeAddr(prog, outputAddr, 0)
			}
		case OpRelBaseOffset:
			in1 := getValue(prog, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			prog.relativeBase += in1
		case OpHalt:
			return
		default:
			panic(fmt.Sprintf("unrecognized opcode: %d", cmd.opcode))
		}

		if !didJump {
			prog.instPtr += cmd.instructionSize()
		}
	}
}

func writeAddr(prog *program, addr, value int64) {
	if addr >= int64(len(prog.instructions)) {
		prog.memory[addr-int64(len(prog.instructions))] = value
	} else {
		prog.instructions[addr] = value
	}
}

func readAddr(prog *program, addr int64) int64 {
	if addr >= int64(len(prog.instructions)) {
		return prog.memory[addr-int64(len(prog.instructions))]
	}

	return prog.instructions[addr]
}

func getAddr(prog *program, param int64, posMode PosMode) int64 {
	if posMode == PosModeAddress {
		return param
	} else if posMode == PosModeRelative {
		return prog.relativeBase + param
	}

	panic("trying to read address when pos mode is value")
}

func getValue(prog *program, param int64, posMode PosMode) int64 {
	var res int64
	if posMode == PosModeAddress {
		res = readAddr(prog, param)
	} else if posMode == PosModeRelative {
		res = readAddr(prog, prog.relativeBase+param)
	} else {
		res = param
	}

	return res
}

var initProgram = []int64{
	3, 8, 1005, 8, 310, 1106, 0, 11, 0, 0, 0, 104, 1, 104, 0, 3, 8, 102, -1, 8, 10, 1001, 10, 1, 10, 4, 10, 108, 1, 8, 10, 4, 10, 1002, 8, 1, 28, 1, 105, 11, 10, 3, 8, 102, -1, 8, 10, 1001, 10, 1, 10, 4, 10, 1008, 8, 0, 10, 4, 10, 102, 1, 8, 55, 3, 8, 102, -1, 8, 10, 1001, 10, 1, 10, 4, 10, 108, 0, 8, 10, 4, 10, 1001, 8, 0, 76, 3, 8, 1002, 8, -1, 10, 101, 1, 10, 10, 4, 10, 108, 0, 8, 10, 4, 10, 102, 1, 8, 98, 1, 1004, 7, 10, 1006, 0, 60, 3, 8, 102, -1, 8, 10, 1001, 10, 1, 10, 4, 10, 108, 0, 8, 10, 4, 10, 1002, 8, 1, 127, 2, 1102, 4, 10, 1, 1108, 7, 10, 2, 1102, 4, 10, 2, 101, 18, 10, 3, 8, 1002, 8, -1, 10, 1001, 10, 1, 10, 4, 10, 1008, 8, 0, 10, 4, 10, 102, 1, 8, 166, 1006, 0, 28, 3, 8, 1002, 8, -1, 10, 101, 1, 10, 10, 4, 10, 108, 1, 8, 10, 4, 10, 101, 0, 8, 190, 1006, 0, 91, 1, 1108, 5, 10, 3, 8, 1002, 8, -1, 10, 101, 1, 10, 10, 4, 10, 1008, 8, 1, 10, 4, 10, 1002, 8, 1, 220, 1, 1009, 14, 10, 2, 1103, 19, 10, 2, 1102, 9, 10, 2, 1007, 4, 10, 3, 8, 1002, 8, -1, 10, 101, 1, 10, 10, 4, 10, 1008, 8, 1, 10, 4, 10, 101, 0, 8, 258, 2, 3, 0, 10, 1006, 0, 4, 3, 8, 102, -1, 8, 10, 1001, 10, 1, 10, 4, 10, 108, 1, 8, 10, 4, 10, 1001, 8, 0, 286, 1006, 0, 82, 101, 1, 9, 9, 1007, 9, 1057, 10, 1005, 10, 15, 99, 109, 632, 104, 0, 104, 1, 21102, 1, 838479487636, 1, 21102, 327, 1, 0, 1106, 0, 431, 21102, 1, 932813579156, 1, 21102, 1, 338, 0, 1106, 0, 431, 3, 10, 104, 0, 104, 1, 3, 10, 104, 0, 104, 0, 3, 10, 104, 0, 104, 1, 3, 10, 104, 0, 104, 1, 3, 10, 104, 0, 104, 0, 3, 10, 104, 0, 104, 1, 21101, 0, 179318033447, 1, 21101, 385, 0, 0, 1105, 1, 431, 21101, 248037678275, 0, 1, 21101, 0, 396, 0, 1105, 1, 431, 3, 10, 104, 0, 104, 0, 3, 10, 104, 0, 104, 0, 21101, 0, 709496558348, 1, 21102, 419, 1, 0, 1105, 1, 431, 21101, 825544561408, 0, 1, 21101, 0, 430, 0, 1106, 0, 431, 99, 109, 2, 22101, 0, -1, 1, 21101, 40, 0, 2, 21102, 462, 1, 3, 21101, 0, 452, 0, 1106, 0, 495, 109, -2, 2105, 1, 0, 0, 1, 0, 0, 1, 109, 2, 3, 10, 204, -1, 1001, 457, 458, 473, 4, 0, 1001, 457, 1, 457, 108, 4, 457, 10, 1006, 10, 489, 1101, 0, 0, 457, 109, -2, 2106, 0, 0, 0, 109, 4, 2101, 0, -1, 494, 1207, -3, 0, 10, 1006, 10, 512, 21101, 0, 0, -3, 22101, 0, -3, 1, 22101, 0, -2, 2, 21101, 1, 0, 3, 21102, 531, 1, 0, 1105, 1, 536, 109, -4, 2105, 1, 0, 109, 5, 1207, -3, 1, 10, 1006, 10, 559, 2207, -4, -2, 10, 1006, 10, 559, 22101, 0, -4, -4, 1106, 0, 627, 21202, -4, 1, 1, 21201, -3, -1, 2, 21202, -2, 2, 3, 21102, 578, 1, 0, 1105, 1, 536, 22101, 0, 1, -4, 21101, 1, 0, -1, 2207, -4, -2, 10, 1006, 10, 597, 21102, 0, 1, -1, 22202, -2, -1, -2, 2107, 0, -3, 10, 1006, 10, 619, 21201, -1, 0, 1, 21102, 1, 619, 0, 105, 1, 494, 21202, -2, -1, -2, 22201, -4, -2, -4, 109, -5, 2106, 0, 0,
}

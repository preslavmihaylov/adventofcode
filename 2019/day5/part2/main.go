package main

import (
	"fmt"
)

const maxArguments = 3

// OpCode ...
type OpCode int

// opcodes
const (
	OpAdd         OpCode = 1
	OpMultiply           = 2
	OpInput              = 3
	OpOutput             = 4
	OpJumpIfTrue         = 5
	OpJumpIfFalse        = 6
	OpLessThan           = 7
	OpEquals             = 8
	OpHalt               = 99
)

// PosMode ...
type PosMode int

// pos modes
const (
	PosModeAddress PosMode = 0
	PosModeValue           = 1
)

func newCommand(inst int) *command {
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

func (c *command) instructionSize() int {
	if c.opcode == OpInput || c.opcode == OpOutput {
		return 2
	} else if c.opcode == OpJumpIfTrue || c.opcode == OpJumpIfFalse {
		return 3
	}

	return 4
}

func main() {
	run(program)
}

func run(program []int) {
	instPtr := 0
	for {
		cmd := newCommand(program[instPtr])

		didJump := false
		switch cmd.opcode {
		case OpAdd:
			in1 := getValue(program, program[instPtr+1], cmd.posModes[0])
			in2 := getValue(program, program[instPtr+2], cmd.posModes[1])
			outputAddr := program[instPtr+3]

			program[outputAddr] = in1 + in2
		case OpMultiply:
			in1 := getValue(program, program[instPtr+1], cmd.posModes[0])
			in2 := getValue(program, program[instPtr+2], cmd.posModes[1])
			outputAddr := program[instPtr+3]

			program[outputAddr] = in1 * in2
		case OpInput:
			var val int
			fmt.Printf("input: ")
			fmt.Scanf("%d", &val)
			outputAddr := program[instPtr+1]

			program[outputAddr] = val

		case OpOutput:
			in1 := getValue(program, program[instPtr+1], PosModeAddress)

			fmt.Println(in1)
		case OpJumpIfTrue:
			in1 := getValue(program, program[instPtr+1], cmd.posModes[0])
			in2 := getValue(program, program[instPtr+2], cmd.posModes[1])

			if in1 != 0 {
				didJump = true
				instPtr = in2
			}
		case OpJumpIfFalse:
			in1 := getValue(program, program[instPtr+1], cmd.posModes[0])

			in2 := getValue(program, program[instPtr+2], cmd.posModes[1])

			if in1 == 0 {
				didJump = true
				instPtr = in2
			}
		case OpLessThan:
			in1 := getValue(program, program[instPtr+1], cmd.posModes[0])
			in2 := getValue(program, program[instPtr+2], cmd.posModes[1])
			outputAddr := program[instPtr+3]

			if in1 < in2 {
				program[outputAddr] = 1
			} else {
				program[outputAddr] = 0
			}
		case OpEquals:
			in1 := getValue(program, program[instPtr+1], cmd.posModes[0])
			in2 := getValue(program, program[instPtr+2], cmd.posModes[1])
			outputAddr := program[instPtr+3]

			if in1 == in2 {
				program[outputAddr] = 1
			} else {
				program[outputAddr] = 0
			}
		case OpHalt:
			return
		default:
			panic(fmt.Sprintf("unrecognized opcode: %d", cmd.opcode))
		}

		if !didJump {
			instPtr += cmd.instructionSize()
		}
	}
}

func getValue(program []int, param int, posMode PosMode) int {
	var res int
	if posMode == PosModeAddress {
		res = program[param]
	} else {
		res = param
	}

	return res
}

var program = []int{
	3, 225, 1, 225, 6, 6, 1100, 1, 238, 225, 104, 0, 2, 171, 209, 224, 1001, 224, -1040, 224, 4, 224, 102, 8, 223, 223, 1001, 224, 4, 224, 1, 223, 224, 223, 102, 65, 102, 224, 101, -3575, 224, 224, 4, 224, 102, 8, 223, 223, 101, 2, 224, 224, 1, 223, 224, 223, 1102, 9, 82, 224, 1001, 224, -738, 224, 4, 224, 102, 8, 223, 223, 1001, 224, 2, 224, 1, 223, 224, 223, 1101, 52, 13, 224, 1001, 224, -65, 224, 4, 224, 1002, 223, 8, 223, 1001, 224, 6, 224, 1, 223, 224, 223, 1102, 82, 55, 225, 1001, 213, 67, 224, 1001, 224, -126, 224, 4, 224, 102, 8, 223, 223, 1001, 224, 7, 224, 1, 223, 224, 223, 1, 217, 202, 224, 1001, 224, -68, 224, 4, 224, 1002, 223, 8, 223, 1001, 224, 1, 224, 1, 224, 223, 223, 1002, 176, 17, 224, 101, -595, 224, 224, 4, 224, 102, 8, 223, 223, 101, 2, 224, 224, 1, 224, 223, 223, 1102, 20, 92, 225, 1102, 80, 35, 225, 101, 21, 205, 224, 1001, 224, -84, 224, 4, 224, 1002, 223, 8, 223, 1001, 224, 1, 224, 1, 224, 223, 223, 1101, 91, 45, 225, 1102, 63, 5, 225, 1101, 52, 58, 225, 1102, 59, 63, 225, 1101, 23, 14, 225, 4, 223, 99, 0, 0, 0, 677, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1105, 0, 99999, 1105, 227, 247, 1105, 1, 99999, 1005, 227, 99999, 1005, 0, 256, 1105, 1, 99999, 1106, 227, 99999, 1106, 0, 265, 1105, 1, 99999, 1006, 0, 99999, 1006, 227, 274, 1105, 1, 99999, 1105, 1, 280, 1105, 1, 99999, 1, 225, 225, 225, 1101, 294, 0, 0, 105, 1, 0, 1105, 1, 99999, 1106, 0, 300, 1105, 1, 99999, 1, 225, 225, 225, 1101, 314, 0, 0, 106, 0, 0, 1105, 1, 99999, 1008, 677, 677, 224, 1002, 223, 2, 223, 1006, 224, 329, 101, 1, 223, 223, 1108, 226, 677, 224, 1002, 223, 2, 223, 1006, 224, 344, 101, 1, 223, 223, 7, 677, 226, 224, 102, 2, 223, 223, 1006, 224, 359, 1001, 223, 1, 223, 8, 677, 226, 224, 102, 2, 223, 223, 1005, 224, 374, 1001, 223, 1, 223, 1107, 677, 226, 224, 102, 2, 223, 223, 1006, 224, 389, 1001, 223, 1, 223, 1008, 226, 226, 224, 1002, 223, 2, 223, 1005, 224, 404, 1001, 223, 1, 223, 7, 226, 677, 224, 102, 2, 223, 223, 1005, 224, 419, 1001, 223, 1, 223, 1007, 677, 677, 224, 102, 2, 223, 223, 1006, 224, 434, 1001, 223, 1, 223, 107, 226, 226, 224, 1002, 223, 2, 223, 1005, 224, 449, 1001, 223, 1, 223, 1008, 677, 226, 224, 102, 2, 223, 223, 1006, 224, 464, 1001, 223, 1, 223, 1007, 677, 226, 224, 1002, 223, 2, 223, 1005, 224, 479, 1001, 223, 1, 223, 108, 677, 677, 224, 1002, 223, 2, 223, 1006, 224, 494, 1001, 223, 1, 223, 108, 226, 226, 224, 1002, 223, 2, 223, 1006, 224, 509, 101, 1, 223, 223, 8, 226, 677, 224, 102, 2, 223, 223, 1006, 224, 524, 101, 1, 223, 223, 107, 677, 226, 224, 1002, 223, 2, 223, 1005, 224, 539, 1001, 223, 1, 223, 8, 226, 226, 224, 102, 2, 223, 223, 1005, 224, 554, 101, 1, 223, 223, 1108, 677, 226, 224, 102, 2, 223, 223, 1006, 224, 569, 101, 1, 223, 223, 108, 677, 226, 224, 102, 2, 223, 223, 1006, 224, 584, 1001, 223, 1, 223, 7, 677, 677, 224, 1002, 223, 2, 223, 1005, 224, 599, 101, 1, 223, 223, 1007, 226, 226, 224, 102, 2, 223, 223, 1005, 224, 614, 1001, 223, 1, 223, 1107, 226, 677, 224, 102, 2, 223, 223, 1006, 224, 629, 101, 1, 223, 223, 1107, 226, 226, 224, 102, 2, 223, 223, 1005, 224, 644, 1001, 223, 1, 223, 1108, 677, 677, 224, 1002, 223, 2, 223, 1005, 224, 659, 101, 1, 223, 223, 107, 677, 677, 224, 1002, 223, 2, 223, 1006, 224, 674, 1001, 223, 1, 223, 4, 223, 99, 226,
}

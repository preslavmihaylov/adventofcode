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

type program struct {
	instructions []int
	instPtr      int
	output       int
}

func main() {
	maxOutput := 0
	for a := 5; a < 10; a++ {
		for b := 5; b < 10; b++ {
			for c := 5; c < 10; c++ {
				for d := 5; d < 10; d++ {
					for e := 5; e < 10; e++ {
						if a == b || a == c || a == d || a == e ||
							b == c || b == d || b == e ||
							c == d || c == e ||
							d == e {
							continue
						}

						prog1 := &program{instructions: make([]int, len(initProgram)), instPtr: 0, output: 0}
						prog2 := &program{instructions: make([]int, len(initProgram)), instPtr: 0, output: 0}
						prog3 := &program{instructions: make([]int, len(initProgram)), instPtr: 0, output: 0}
						prog4 := &program{instructions: make([]int, len(initProgram)), instPtr: 0, output: 0}
						prog5 := &program{instructions: make([]int, len(initProgram)), instPtr: 0, output: 0}

						copy(prog1.instructions, initProgram)
						copy(prog2.instructions, initProgram)
						copy(prog3.instructions, initProgram)
						copy(prog4.instructions, initProgram)
						copy(prog5.instructions, initProgram)

						halted := false
						for !halted {
							_ = run(prog1, []int{a, prog5.output})
							_ = run(prog2, []int{b, prog1.output})
							_ = run(prog3, []int{c, prog2.output})
							_ = run(prog4, []int{d, prog3.output})
							halted = run(prog5, []int{e, prog4.output})
						}

						if maxOutput < prog5.output {
							maxOutput = prog5.output
						}
					}
				}
			}
		}
	}

	fmt.Println(maxOutput)
}

func run(prog *program, inputs []int) bool {
	outputChanged := false
	inputIndex := 0
	if prog.instPtr != 0 {
		inputIndex = 1
	}

	for {
		if outputChanged {
			return false
		}

		cmd := newCommand(prog.instructions[prog.instPtr])

		didJump := false
		switch cmd.opcode {
		case OpAdd:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog.instructions, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := prog.instructions[prog.instPtr+3]

			prog.instructions[outputAddr] = in1 + in2
		case OpMultiply:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog.instructions, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := prog.instructions[prog.instPtr+3]

			prog.instructions[outputAddr] = in1 * in2
		case OpInput:
			val := inputs[inputIndex]
			inputIndex++

			outputAddr := prog.instructions[prog.instPtr+1]

			prog.instructions[outputAddr] = val

		case OpOutput:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], PosModeAddress)

			outputChanged = true
			prog.output = in1
		case OpJumpIfTrue:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog.instructions, prog.instructions[prog.instPtr+2], cmd.posModes[1])

			if in1 != 0 {
				didJump = true
				prog.instPtr = in2
			}
		case OpJumpIfFalse:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], cmd.posModes[0])

			in2 := getValue(prog.instructions, prog.instructions[prog.instPtr+2], cmd.posModes[1])

			if in1 == 0 {
				didJump = true
				prog.instPtr = in2
			}
		case OpLessThan:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog.instructions, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := prog.instructions[prog.instPtr+3]

			if in1 < in2 {
				prog.instructions[outputAddr] = 1
			} else {
				prog.instructions[outputAddr] = 0
			}
		case OpEquals:
			in1 := getValue(prog.instructions, prog.instructions[prog.instPtr+1], cmd.posModes[0])
			in2 := getValue(prog.instructions, prog.instructions[prog.instPtr+2], cmd.posModes[1])
			outputAddr := prog.instructions[prog.instPtr+3]

			if in1 == in2 {
				prog.instructions[outputAddr] = 1
			} else {
				prog.instructions[outputAddr] = 0
			}
		case OpHalt:
			return true
		default:
			panic(fmt.Sprintf("unrecognized opcode: %d", cmd.opcode))
		}

		if !didJump {
			prog.instPtr += cmd.instructionSize()
		}
	}
}

func getValue(instructions []int, param int, posMode PosMode) int {
	var res int
	if posMode == PosModeAddress {
		res = instructions[param]
	} else {
		res = param
	}

	return res
}

var initProgram = []int{
	3, 8, 1001, 8, 10, 8, 105, 1, 0, 0, 21, 38, 47, 64, 85, 106, 187, 268, 349, 430, 99999, 3, 9, 1002, 9, 4, 9, 1001, 9, 4, 9, 1002, 9, 4, 9, 4, 9, 99, 3, 9, 1002, 9, 4, 9, 4, 9, 99, 3, 9, 1001, 9, 3, 9, 102, 5, 9, 9, 1001, 9, 5, 9, 4, 9, 99, 3, 9, 101, 3, 9, 9, 102, 5, 9, 9, 1001, 9, 4, 9, 102, 4, 9, 9, 4, 9, 99, 3, 9, 1002, 9, 3, 9, 101, 2, 9, 9, 102, 4, 9, 9, 101, 2, 9, 9, 4, 9, 99, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1001, 9, 2, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 101, 2, 9, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 99, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 1001, 9, 2, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 101, 2, 9, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 99, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 99, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 101, 2, 9, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 99, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 101, 1, 9, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 3, 9, 1001, 9, 2, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 1002, 9, 2, 9, 4, 9, 3, 9, 1001, 9, 1, 9, 4, 9, 3, 9, 102, 2, 9, 9, 4, 9, 99,
}

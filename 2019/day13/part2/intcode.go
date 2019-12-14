package main

import (
	"fmt"
)

const maxArguments = 3

func newProgram(instructions []int64) *program {
	p := &program{
		instructions: make([]int64, len(instructions)),
		memory:       make(map[int64]int64),
		instPtr:      0,
		relativeBase: 0,
	}

	copy(p.instructions, instructions)
	return p
}

type program struct {
	instructions []int64
	memory       map[int64]int64
	instPtr      int64
	relativeBase int64
}

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

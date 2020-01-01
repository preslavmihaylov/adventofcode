package main

import "fmt"

var instructionIndex = 0
var instructions = []string{
	// if (at least one hole in next three tiles) AND (ground on fourth tile)
	// (!A || !B || !C) && D
	"NOT A T",
	"OR T J",
	"NOT B T",
	"OR T J",
	"NOT C T",
	"OR T J",
	"AND D J",

	// if (previous is true) AND ((eight tile is free) OR (fifth tile is free))
	// J && (H || E)
	"NOT J T",
	"OR H T",
	"OR E T",
	"AND T J",
	"RUN",
}

func main() {
	prog := newProgram(initProgram)
	run(prog, inputCallback, outputCallback)
}

func inputLineCallback() string {
	if instructionIndex >= len(instructions) {
		panic("instruction index out of range")
	}

	res := instructions[instructionIndex]
	instructionIndex++

	return res
}

func outputLineCallback(line string) {
	fmt.Println(line)
}

func resultCallback(res int64) {
	fmt.Println("RESULT:", res)
}

package main

import "fmt"

var instructionIndex = 0
var instructions = []string{
	"NOT A T",
	"OR T J",
	"NOT B T",
	"OR T J",
	"NOT C T",
	"OR T J",
	"AND D J",
	"WALK",
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

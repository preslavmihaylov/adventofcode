package main

import (
	"bufio"
	"fmt"
	"os"
)

const (
	newline = '\n'
)

var stdoutReader = bufio.NewReader(os.Stdin)
var input string
var inputIndex = 0

var output string

func main() {
	prog := newProgram(initProgram)
	run(prog, inputCallback, outputCallback)
}
func inputCallback() int64 {
	if input == "" {
		input = readInput()
		inputIndex = 0
	}

	if inputIndex >= len(input) {
		input = ""

		return newline
	}

	ch := int64(input[inputIndex])
	inputIndex++

	return ch
}

func outputCallback(val int64) {
	if val == newline {
		fmt.Println(output)
		output = ""

		return
	}

	output += string(val)
}

func readInput() string {
	res, err := stdoutReader.ReadString('\n')
	if err != nil {
		panic(err)
	}

	res = res[:len(res)-1]
	switch res {
	case "w":
		return "north"
	case "d":
		return "east"
	case "s":
		return "south"
	case "a":
		return "west"
	default:
		return res
	}
}

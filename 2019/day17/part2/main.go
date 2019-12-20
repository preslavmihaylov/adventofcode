package main

import (
	"fmt"
)

// Point ...
type Point struct {
	row, col int
}

// Direction ...
type Direction int

// ...
const (
	DirectionUp    Direction = iota
	DirectionRight           = iota
	DirectionDown            = iota
	DirectionLeft            = iota
)

var row, col = 0, 0
var startingPoint = Point{}

var solutionRow, solutionCol = 0, 0

// I calculated it by hand :S
var solution = []string{
	"A,B,A,C,B,C,B,C,A,C\n",
	"L,10,R,12,R,12\n",
	"R,6,R,10,L,10\n",
	"R,10,L,10,L,12,R,6\n",
	"n\n",
}

func main() {
	initScreen()

	prog := newProgram(initProgram)
	prog.instructions[0] = 2

	run(prog, inputCallback, outputCallback)
}

func inputCallback() int64 {
	res := solution[solutionRow][solutionCol]
	solutionCol++

	if solutionCol >= len(solution[solutionRow]) {
		solutionRow++
		solutionCol = 0
	}

	return int64(res)
}

func outputCallback(val int64) {
	fmt.Println(val)
}

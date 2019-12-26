package main

import (
	"fmt"
)

// InputState ...
type InputState int

// ...
const (
	InputStateCol    InputState = iota
	InputStateRow               = iota
	InputStatesCnt              = iota
	InputStateFinish            = iota
)

var dimensions int64 = 100
var grid [][]rune

var row, col int64 = 0, 0
var inputState = InputStateCol

func main() {
	grid = initGrid()

	for inputState != InputStateFinish {
		prog := newProgram(initProgram)
		run(prog, inputCallback, outputCallback)
	}

	printGrid()
	fmt.Println(countAffectedCells())
}

func initGrid() [][]rune {
	grid := make([][]rune, dimensions)
	for row := range grid {
		grid[row] = make([]rune, dimensions)
	}

	return grid
}

func countAffectedCells() int {
	cnt := 0
	for row := range grid {
		for col := range grid[row] {
			if grid[row][col] == '#' {
				cnt++
			}
		}
	}

	return cnt
}

func inputCallback() int64 {
	var res int64
	switch inputState {
	case InputStateCol:
		res = col
	case InputStateRow:
		res = row
	case InputStateFinish:
		panic("program asked for input in finished state")
	default:
		panic("invalid input state")
	}

	inputState = (inputState + 1) % InputStatesCnt
	return res
}

func outputCallback(val int64) {
	fmt.Println(row, col)
	if val == 0 {
		grid[row][col] = '.'
	} else {
		grid[row][col] = '#'
	}

	col++
	if col >= dimensions {
		row++
		col = 0
	}

	if row >= dimensions {
		inputState = InputStateFinish
	}
}

func printGrid() {
	for row := range grid {
		for col := range grid[row] {
			fmt.Printf("%c", grid[row][col])
		}

		fmt.Println()
	}
}

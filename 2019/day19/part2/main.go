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

var dimensions int64 = 1500
var grid [][]rune

var row, col int64
var firstSeenBeamCol int64
var inputState = InputStateCol

func main() {
	grid = initGrid()

	for inputState != InputStateFinish {
		prog := newProgram(initProgram)
		run(prog, inputCallback, outputCallback)
	}

	row, col, didFit := findFitFor100x100Square()
	if !didFit {
		fmt.Println("A square couldn't fit in these dimensions")
	} else {
		fmt.Printf("(row=%d, col=%d, res=%d)\n", row, col, col*10000+row)
	}
}

func initGrid() [][]rune {
	grid := make([][]rune, dimensions)
	for row := range grid {
		grid[row] = make([]rune, dimensions)
	}

	return grid
}

func findFitFor100x100Square() (int, int, bool) {
	for row := range grid {
		for col := range grid {
			if grid[row][col] == '#' {
				if canFitSquare(row, col) {
					return row - 100 + 1, col, true
				}
			}
		}
	}

	return -1, -1, false
}

func canFitSquare(row, col int) bool {
	endRow := row - 100 + 1
	endCol := col + 100 - 1

	return endRow >= 0 && endRow < len(grid) &&
		endCol >= 0 && endCol < len(grid[endRow]) && grid[endRow][endCol] == '#'
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
	if val == 0 {
		grid[row][col] = '.'
		if col > 0 && grid[row][col-1] == '#' {
			row++
			col = firstSeenBeamCol
			if row >= dimensions {
				inputState = InputStateFinish
			}

			return
		}
	} else {
		grid[row][col] = '#'
		if col > 0 && grid[row][col-1] == '.' {
			firstSeenBeamCol = col
		}
	}

	col++
	if col >= dimensions {
		row++
		col = firstSeenBeamCol
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

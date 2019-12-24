package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

var gridSize = 5

// Direction ...
type Direction int

// ...
const (
	DirectionUp    Direction = iota
	DirectionDown            = iota
	DirectionLeft            = iota
	DirectionRight           = iota
)

var (
	innerGridRow, innerGridCol = 2, 2

	topOuterRow, topOuterCol     = 1, 2
	botOuterRow, botOuterCol     = 3, 2
	leftOuterRow, leftOuterCol   = 2, 1
	rightOuterRow, rightOuterCol = 2, 3

	topInnerRow, topInnerCol     = 1, 2
	botInnerRow, botInnerCol     = 3, 2
	leftInnerRow, leftInnerCol   = 2, 1
	rightInnerRow, rightInnerCol = 2, 3
)

func main() {
	grid := readInput("input.txt")
	levels := [][][]rune{newGrid(), grid, newGrid()}

	levels = fastForwardNSteps(levels, 200)
	fmt.Println(countBugsOnAllLevels(levels))
}

func fastForwardNSteps(levels [][][]rune, n int) [][][]rune {
	for i := 0; i < n; i++ {
		levels = makeStep(levels)
		if countBugsOnGrid(levels[0]) > 0 {
			levels = append([][][]rune{newGrid()}, levels...)
		}

		if countBugsOnGrid(levels[len(levels)-1]) > 0 {
			levels = append(levels, newGrid())
		}
	}

	return levels
}

func makeStep(levels [][][]rune) [][][]rune {
	innerGrid := newGrid()
	var outerGrid [][]rune
	for i, grid := range levels {
		if i < len(levels)-1 {
			outerGrid = levels[i+1]
		} else {
			outerGrid = newGrid()
		}

		gridCopy := copyGrid(grid)
		for row := range grid {
			for col := range grid[row] {
				if row == innerGridRow && col == innerGridCol {
					continue
				}

				if grid[row][col] == '#' && bugDies(innerGrid, grid, outerGrid, row, col) {
					gridCopy[row][col] = '.'
				} else if grid[row][col] == '.' && becomesInfested(innerGrid, grid, outerGrid, row, col) {
					gridCopy[row][col] = '#'
				}
			}
		}

		innerGrid = copyGrid(grid)
		for row := 0; row < 5; row++ {
			copy(levels[i][row], gridCopy[row])
		}
	}

	return levels
}

func bugDies(prevGrid, grid, nextGrid [][]rune, row, col int) bool {
	return countAdjacentBugs(prevGrid, grid, nextGrid, row, col) != 1
}

func becomesInfested(prevGrid, grid, nextGrid [][]rune, row, col int) bool {
	return countAdjacentBugs(prevGrid, grid, nextGrid, row, col) == 1 ||
		countAdjacentBugs(prevGrid, grid, nextGrid, row, col) == 2
}

func countAdjacentBugs(prevGrid, grid, nextGrid [][]rune, row, col int) int {
	adjacentBugsCnt := countBugsOnCell(prevGrid, grid, nextGrid, row-1, col, DirectionUp)
	adjacentBugsCnt += countBugsOnCell(prevGrid, grid, nextGrid, row, col+1, DirectionRight)
	adjacentBugsCnt += countBugsOnCell(prevGrid, grid, nextGrid, row+1, col, DirectionDown)
	adjacentBugsCnt += countBugsOnCell(prevGrid, grid, nextGrid, row, col-1, DirectionLeft)

	return adjacentBugsCnt
}

func countBugsOnCell(outerGrid, grid, innerGrid [][]rune, row, col int, dir Direction) int {
	if row == innerGridRow && col == innerGridCol {
		return countBugsInInnerGrid(innerGrid, dir)
	}

	var cellValue rune
	if row >= 0 && row < len(grid) && col >= 0 && col < len(grid[row]) {
		cellValue = grid[row][col]
	} else if row < 0 {
		cellValue = outerGrid[topOuterRow][topOuterCol]
	} else if row >= len(grid) {
		cellValue = outerGrid[botOuterRow][botOuterCol]
	} else if col < 0 {
		cellValue = outerGrid[leftOuterRow][leftOuterCol]
	} else {
		cellValue = outerGrid[rightOuterRow][rightOuterCol]
	}

	if cellValue == '#' {
		return 1
	}

	return 0
}

func countBugsInInnerGrid(innerGrid [][]rune, dir Direction) int {
	bugsCnt := 0
	if dir == DirectionUp {
		row := gridSize - 1
		for col := 0; col < gridSize; col++ {
			if innerGrid[row][col] == '#' {
				bugsCnt++
			}
		}
	} else if dir == DirectionDown {
		row := 0
		for col := 0; col < gridSize; col++ {
			if innerGrid[row][col] == '#' {
				bugsCnt++
			}
		}
	} else if dir == DirectionLeft {
		col := gridSize - 1
		for row := 0; row < gridSize; row++ {
			if innerGrid[row][col] == '#' {
				bugsCnt++
			}
		}
	} else {
		col := 0
		for row := 0; row < gridSize; row++ {
			if innerGrid[row][col] == '#' {
				bugsCnt++
			}
		}
	}

	return bugsCnt
}

func readInput(filename string) [][]rune {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(bs), "\n")
	lines = lines[:len(lines)-1]

	grid := make([][]rune, len(lines))
	for row := range lines {
		grid[row] = make([]rune, len(lines[row]))
		for col := range lines[row] {
			grid[row][col] = rune(lines[row][col])
		}
	}

	return grid
}

func printGrids(levels [][][]rune) {
	for i, grid := range levels {
		fmt.Printf("\tLevel %d\n", i)
		for row := range grid {
			fmt.Print("\t")
			for col := range grid[row] {
				fmt.Printf("%c", grid[row][col])
			}

			fmt.Println()
		}

		fmt.Println()
	}
}

func countBugsOnAllLevels(levels [][][]rune) int {
	bugsCnt := 0
	for _, grid := range levels {
		bugsCnt += countBugsOnGrid(grid)
	}

	return bugsCnt
}

func countBugsOnGrid(grid [][]rune) int {
	bugsCnt := 0
	for row := range grid {
		for col := range grid[row] {
			if grid[row][col] == '#' {
				bugsCnt++
			}
		}
	}

	return bugsCnt
}

func newGrid() [][]rune {
	newGrid := make([][]rune, gridSize)
	for row := 0; row < gridSize; row++ {
		newGrid[row] = make([]rune, gridSize)
		for col := 0; col < gridSize; col++ {
			newGrid[row][col] = '.'
		}
	}

	return newGrid
}

func copyGrid(grid [][]rune) [][]rune {
	newGrid := make([][]rune, len(grid))
	for row := range grid {
		newGrid[row] = make([]rune, len(grid[row]))
		copy(newGrid[row], grid[row])
	}

	return newGrid
}

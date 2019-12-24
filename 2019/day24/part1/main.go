package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

func main() {
	grid := readInput("input.txt")
	findFirstRepeatedLayout(grid)
	fmt.Println(calcBiodiversityRating(grid))
}

func findFirstRepeatedLayout(grid [][]rune) {
	stateSeen := map[int64]bool{}
	stateSeen[stateHash(grid)] = true

	for {
		makeStep(grid)
		hash := stateHash(grid)
		if stateSeen[hash] {
			return
		}

		stateSeen[hash] = true
	}
}

func stateHash(grid [][]rune) int64 {
	hash := int64(17)
	for row := range grid {
		for col := range grid {
			hash = hash*31 + int64(grid[row][col])
		}
	}

	return hash
}

func makeStep(grid [][]rune) {
	nextGrid := copyGrid(grid)
	for row := range grid {
		for col := range grid[row] {
			if grid[row][col] == '#' && bugDies(grid, row, col) {
				nextGrid[row][col] = '.'
			} else if grid[row][col] == '.' && becomesInfested(grid, row, col) {
				nextGrid[row][col] = '#'
			}
		}
	}

	for row := range grid {
		copy(grid[row], nextGrid[row])
	}
}

func bugDies(grid [][]rune, row, col int) bool {
	return countAdjacentBugs(grid, row, col) != 1
}

func becomesInfested(grid [][]rune, row, col int) bool {
	return countAdjacentBugs(grid, row, col) == 1 || countAdjacentBugs(grid, row, col) == 2
}

func countAdjacentBugs(grid [][]rune, row, col int) int {
	adjacentBugsCnt := 0
	if isBug(grid, row-1, col) {
		adjacentBugsCnt++
	}
	if isBug(grid, row, col+1) {
		adjacentBugsCnt++
	}
	if isBug(grid, row+1, col) {
		adjacentBugsCnt++
	}
	if isBug(grid, row, col-1) {
		adjacentBugsCnt++
	}

	return adjacentBugsCnt
}

func isBug(grid [][]rune, row, col int) bool {
	return row >= 0 && row < len(grid) && col >= 0 && col < len(grid[row]) && grid[row][col] == '#'
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

func printGrid(grid [][]rune) {
	for row := range grid {
		for col := range grid[row] {
			fmt.Printf("%c", grid[row][col])
		}

		fmt.Println()
	}
}

func calcBiodiversityRating(grid [][]rune) int64 {
	multiple := int64(1)
	result := int64(0)
	for row := range grid {
		for col := range grid[row] {
			if grid[row][col] == '#' {
				result += multiple
			}

			multiple *= 2
		}
	}

	return result
}

func copyGrid(grid [][]rune) [][]rune {
	newGrid := make([][]rune, len(grid))
	for row := range grid {
		newGrid[row] = make([]rune, len(grid[row]))
		copy(newGrid[row], grid[row])
	}

	return newGrid
}

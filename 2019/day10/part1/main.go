package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

type asteroid struct {
	row, col int
}

func main() {
	grid := readInput("input.txt")
	asteroids := getAsteroids(grid)

	maxVisibility := 0
	for i := range asteroids {
		visibility := findVisibility(grid, asteroids, i)
		if maxVisibility < visibility {
			maxVisibility = visibility
		}
	}

	fmt.Println(maxVisibility)
}

func findVisibility(mainGrid [][]rune, asteroids []asteroid, astIndex int) int {
	grid := copyGrid(mainGrid)
	curr := asteroids[astIndex]
	for i := range asteroids {
		if i == astIndex {
			continue
		}

		other := asteroids[i]
		if grid[other.row][other.col] == '#' {
			grid[other.row][other.col] = 'X'
		}

		currRowOffset := other.row - curr.row
		currColOffset := other.col - curr.col
		rowOffset := currRowOffset / gcd(currRowOffset, currColOffset)
		colOffset := currColOffset / gcd(currRowOffset, currColOffset)

		currRowOffset += rowOffset
		currColOffset += colOffset

		for currRowOffset+curr.row >= 0 && currRowOffset+curr.row < len(grid) &&
			currColOffset+curr.col >= 0 && currColOffset+curr.col < len(grid) {

			grid[currRowOffset+curr.row][currColOffset+curr.col] = '.'

			currRowOffset += rowOffset
			currColOffset += colOffset
		}
	}

	return countVisibleAsteroids(grid)
}

func gcd(a, b int) int {
	if a < 0 {
		a = -a
	}
	if b < 0 {
		b = -b
	}

	if b > a {
		tmp := b
		b = a
		a = tmp
	}

	for b != 0 {
		tmp := b
		b = a % b
		a = tmp
	}

	return a
}

func countVisibleAsteroids(grid [][]rune) int {
	cnt := 0
	for r := range grid {
		for c := range grid {
			if grid[r][c] == 'X' {
				cnt++
			}
		}
	}

	return cnt
}

func getAsteroids(grid [][]rune) []asteroid {
	res := []asteroid{}
	for row := range grid {
		for col := range grid[row] {
			if grid[row][col] == '#' {
				res = append(res, asteroid{row: row, col: col})
			}
		}
	}

	return res
}

func readInput(filename string) [][]rune {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	result := [][]rune{}
	lines := strings.Split(string(bs), "\n")
	for r, line := range lines {
		if line == "" {
			continue
		}

		result = append(result, []rune{})
		for _, ch := range line {
			result[r] = append(result[r], ch)
		}
	}

	return result
}

func copyGrid(grid [][]rune) [][]rune {
	other := make([][]rune, len(grid))
	for r := range grid {
		other[r] = make([]rune, len(grid[r]))
		copy(other[r], grid[r])
	}

	return other
}

func printGrid(grid [][]rune) {
	for r := range grid {
		for c := range grid {
			fmt.Print(string(grid[r][c]))
		}

		fmt.Println()
	}
}

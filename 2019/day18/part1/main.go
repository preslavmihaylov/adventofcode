package main

import (
	"fmt"
	"hash/fnv"
	"io/ioutil"
	"math"
	"strings"
	"unicode"
)

// Point ...
type Point struct {
	row, col int
}

// Key ...
type Key struct {
	Point
	steps int
}

var initGrid [][]rune
var startingPos Point

func main() {
	startingPos = readInput("input.txt")

	fmt.Println(shortestPath(initGrid, startingPos, make(map[int64]int)))
}

func shortestPath(grid [][]rune, pos Point, memo map[int64]int) int {
	keys := findReachableKeys(grid, pos)
	stateHash := serializeState(grid)
	if _, ok := memo[stateHash]; ok {
		return memo[stateHash]
	}

	if len(keys) == 0 {
		return 0
	}

	minPath := math.MaxInt32
	cnt := 0
	for _, key := range keys {
		if pos == startingPos {
			fmt.Println("STEP:", cnt)
		}

		g, p := removeKey(grid, pos, key)
		minPath = intMin(minPath, key.steps+shortestPath(g, p, memo))

		cnt++
	}

	memo[stateHash] = minPath

	return minPath
}

func findReachableKeys(grid [][]rune, pos Point) []Key {
	return bfs(grid, pos)
}

func bfs(grid [][]rune, pos Point) []Key {
	type Step struct {
		Point
		steps int
	}

	visited := make([][]bool, len(grid))
	for row := range grid {
		visited[row] = make([]bool, len(grid[row]))
	}

	queue := []Step{}
	queue = append(queue, Step{pos, 0})

	keys := []Key{}
	for len(queue) > 0 {
		step := queue[0]
		queue = queue[1:]

		p := step.Point
		if p.row < 0 || p.row >= len(grid) || p.col < 0 || p.col >= len(grid[p.row]) {
			continue
		} else if grid[p.row][p.col] == '#' || unicode.IsUpper(grid[p.row][p.col]) {
			continue
		} else if visited[p.row][p.col] {
			continue
		}

		if unicode.IsLower(grid[p.row][p.col]) {
			keys = append(keys, Key{p, step.steps})
		}

		visited[p.row][p.col] = true
		queue = append(queue, Step{Point{p.row - 1, p.col}, step.steps + 1})
		queue = append(queue, Step{Point{p.row, p.col + 1}, step.steps + 1})
		queue = append(queue, Step{Point{p.row + 1, p.col}, step.steps + 1})
		queue = append(queue, Step{Point{p.row, p.col - 1}, step.steps + 1})

		// diagonals
		queue = append(queue, Step{Point{p.row - 1, p.col - 1}, step.steps + 1})
		queue = append(queue, Step{Point{p.row - 1, p.col + 1}, step.steps + 1})
		queue = append(queue, Step{Point{p.row + 1, p.col - 1}, step.steps + 1})
		queue = append(queue, Step{Point{p.row + 1, p.col + 1}, step.steps + 1})
	}

	return keys
}

func removeKey(grid [][]rune, pos Point, key Key) ([][]rune, Point) {
	newGrid := make([][]rune, len(grid))
	for row := range grid {
		newGrid[row] = make([]rune, len(grid[row]))
		copy(newGrid[row], grid[row])
	}

	keyLetter := grid[key.row][key.col]
	for row := range grid {
		for col := range grid[row] {
			if newGrid[row][col] == unicode.ToUpper(keyLetter) {
				newGrid[row][col] = '.'
			}
		}
	}

	newGrid[pos.row][pos.col] = '.'
	newGrid[key.row][key.col] = '@'

	return newGrid, Point{key.row, key.col}
}

func serializeState(grid [][]rune) int64 {
	h := fnv.New32a()
	for row := range grid {
		for col := range grid[row] {
			h.Write([]byte{byte(grid[row][col])})
		}
	}

	return int64(h.Sum32())
}

func intMin(a, b int) int {
	if a < b {
		return a
	}

	return b
}

func readInput(filename string) Point {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(bs), "\n")
	lines = lines[:len(lines)-1]

	var startingPos Point
	initGrid = make([][]rune, len(lines))
	for row := range lines {
		initGrid[row] = make([]rune, len(lines[row]))
		for col := range lines[row] {
			initGrid[row][col] = rune(lines[row][col])
			if initGrid[row][col] == '@' {
				startingPos = Point{row, col}
			}
		}
	}

	return startingPos
}

func printGrid(grid [][]rune) {
	for row := range grid {
		for col := range grid[row] {
			fmt.Print(string(grid[row][col]))
		}

		fmt.Println()
	}
}

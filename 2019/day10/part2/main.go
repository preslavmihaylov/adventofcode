package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"sort"
	"strings"
)

type asteroid struct {
	row, col int
}

func main() {
	grid := readInput("input.txt")
	asteroids := getAsteroids(grid)

	maxVisibility := 0
	monitoringStationIndex := 0
	for i := range asteroids {
		visibility := findVisibility(grid, asteroids, i)
		if maxVisibility < visibility {
			maxVisibility = visibility
			monitoringStationIndex = i
		}
	}

	ast := find200thDestroyedAsteroid(grid, asteroids, monitoringStationIndex)
	fmt.Println(ast.col*100 + ast.row)
}

type sortedByAngle struct {
	center asteroid
	ast    asteroid
}

type sortedByAngles []sortedByAngle

func (s sortedByAngles) Len() int {
	return len(s)
}

func (s sortedByAngles) Less(i, j int) bool {
	return getAngle(s[i].center, s[i].ast) < getAngle(s[j].center, s[j].ast)
}

func (s sortedByAngles) Swap(i, j int) {
	s[i], s[j] = s[j], s[i]
}

func find200thDestroyedAsteroid(mainGrid [][]rune, asteroids []asteroid, astIndex int) asteroid {
	cnt := 0
	destroyedCnt := 0
	for {
		destroyed := getDestroyedAsteroids(mainGrid, asteroids, astIndex)

		if destroyedCnt+len(destroyed) < 200 {
			destroyedCnt += len(destroyed)
			for _, dst := range destroyed {
				fmt.Printf("%d: %v\n", cnt, dst)
				cnt++
			}
		} else {
			sorted := sortedByAngles{}
			for i := range destroyed {
				sorted = append(sorted, sortedByAngle{asteroids[astIndex], destroyed[i]})
			}

			sort.Sort(sorted)
			return sorted[200-destroyedCnt-1].ast
		}

		for _, dest := range destroyed {
			for i := range asteroids {
				if asteroids[i].row == dest.row && asteroids[i].col == dest.col {
					asteroids = append(asteroids[0:i], asteroids[i+1:]...)
				}
			}
		}
	}
}

func getAngle(ast1, ast2 asteroid) float64 {
	dx := ast2.col - ast1.col
	dy := ast2.row - ast1.row
	resRadians := math.Atan2(float64(dy), float64(dx))
	degrees := resRadians * 180 / math.Pi
	if degrees < -90 {
		degrees += 360
	}

	return degrees
}

func getDestroyedAsteroids(mainGrid [][]rune, asteroids []asteroid, astIndex int) []asteroid {
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

	return getVisibleAsteroids(grid)
}

func findVisibleAsteroids(mainGrid [][]rune, asteroids []asteroid, astIndex int) []asteroid {
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

	return getVisibleAsteroids(grid)
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
		a, b = b, a
	}

	for b != 0 {
		a, b = b, a%b
	}

	return a
}

func getVisibleAsteroids(grid [][]rune) []asteroid {
	asteroids := []asteroid{}
	for r := range grid {
		for c := range grid {
			if grid[r][c] == 'X' {
				asteroids = append(asteroids, asteroid{r, c})
			}
		}
	}

	return asteroids
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

package main

import (
	"errors"
	"fmt"
	"io/ioutil"
	"strings"
	"unicode"
)

// Point ...
type Point struct {
	row, col int
}

// Stairs ...
type Stairs struct {
	Point
	isInner bool
}

func (p Point) hash() string {
	return fmt.Sprintf("%d-%d", p.row, p.col)
}

func main() {
	grid := readInput("input.txt")
	labelsToPoints := indexLabels(grid)
	res := findShortestPathFromAAtoZZ(grid, labelsToPoints)
	fmt.Println(res)
}

func findShortestPathFromAAtoZZ(grid [][]rune, labelsToPoints map[string][]Point) int {
	if len(labelsToPoints["AA"]) != 1 || len(labelsToPoints["ZZ"]) != 1 {
		panic("INVARIANT FAILED: AA or ZZ contain more than one point")
	}

	type Step struct {
		point Point
		steps int
		level int
	}

	start, finish := labelsToPoints["AA"][0], labelsToPoints["ZZ"][0]

	visited := make([][][]bool, len(grid))
	for row := range grid {
		visited[row] = make([][]bool, len(grid[row]))
		// visited cells by levels
		for col := range grid[row] {
			visited[row][col] = make([]bool, 5000)
		}
	}

	queue := []Step{Step{start, 0, 0}}
	for len(queue) > 0 {
		step := queue[0]
		p := step.point

		queue = queue[1:]

		if step.level == 0 && p.row == finish.row && p.col == finish.col {
			return step.steps
		}

		up, down, left, right :=
			Point{p.row - 1, p.col}, Point{p.row + 1, p.col},
			Point{p.row, p.col - 1}, Point{p.row, p.col + 1}

		dirs := []Point{up, down, left, right}

		for _, dir := range dirs {
			if !isInBounds(grid, dir) {
				continue
			} else if visited[dir.row][dir.col][step.level] {
				continue
			}

			var nextStep Step
			if grid[dir.row][dir.col] == '.' {
				nextStep = Step{dir, step.steps + 1, step.level}
				queue = append(queue, nextStep)
			} else if unicode.IsUpper(grid[dir.row][dir.col]) {
				label, stairs, err := extractLabel(grid, dir)
				if err != nil {
					panic(err)
				} else if label == "AA" || label == "ZZ" {
					continue
					// no outer layers at level 0
				} else if !stairs.isInner && step.level == 0 {
					continue
				}

				nextStep = Step{getTeleportPoint(labelsToPoints, label, stairs.Point), step.steps + 1, step.level}
				if stairs.isInner {
					nextStep.level++
				} else {
					nextStep.level--
				}

				queue = append(queue, nextStep)
			}

			visited[nextStep.point.row][nextStep.point.col][nextStep.level] = true
		}
	}

	panic("no route found from AA to ZZ")
}

func indexLabels(grid [][]rune) map[string][]Point {
	labelsToPoints := map[string][]Point{}
	for row := range grid {
		for col := range grid[row] {
			if unicode.IsUpper(grid[row][col]) {
				label, stairs, err := extractLabel(grid, Point{row, col})
				if err != nil {
					panic(err)
				}

				if _, ok := labelsToPoints[label]; !ok {
					labelsToPoints[label] = []Point{}
				}

				if !isInside(labelsToPoints[label], stairs.Point) {
					labelsToPoints[label] = append(labelsToPoints[label], stairs.Point)
				}
			}
		}
	}

	return labelsToPoints
}

func getTeleportPoint(labelsToPoints map[string][]Point, label string, p Point) Point {
	ps := labelsToPoints[label]
	if len(ps) != 2 {
		panic(fmt.Sprintf("INVARIANT FAILED: teleport point has more/less than two points: %s", label))
	}

	if p.row == ps[0].row && p.col == ps[0].col {
		return ps[1]
	} else if p.row == ps[1].row && p.col == ps[1].col {
		return ps[0]
	}

	panic("no teleport point found")
}

func extractLabel(grid [][]rune, pos Point) (string, Stairs, error) {
	if !isInBounds(grid, pos) || !unicode.IsUpper(grid[pos.row][pos.col]) {
		return "", Stairs{}, errors.New("failed to extract label")
	}

	up, down, left, right :=
		Point{pos.row - 1, pos.col}, Point{pos.row + 1, pos.col},
		Point{pos.row, pos.col - 1}, Point{pos.row, pos.col + 1}

	var label string
	var firstPortal, secondPortal Point
	if isInBounds(grid, up) && unicode.IsUpper(grid[up.row][up.col]) {
		label = fmt.Sprintf("%c%c", grid[up.row][up.col], grid[pos.row][pos.col])
		firstPortal, secondPortal = Point{pos.row - 2, pos.col}, Point{pos.row + 1, pos.col}
	} else if isInBounds(grid, down) && unicode.IsUpper(grid[down.row][down.col]) {
		label = fmt.Sprintf("%c%c", grid[pos.row][pos.col], grid[down.row][down.col])
		firstPortal, secondPortal = Point{pos.row - 1, pos.col}, Point{pos.row + 2, pos.col}
	} else if isInBounds(grid, left) && unicode.IsUpper(grid[left.row][left.col]) {
		label = fmt.Sprintf("%c%c", grid[left.row][left.col], grid[pos.row][pos.col])
		firstPortal, secondPortal = Point{pos.row, pos.col - 2}, Point{pos.row, pos.col + 1}
	} else if isInBounds(grid, right) && unicode.IsUpper(grid[right.row][right.col]) {
		label = fmt.Sprintf("%c%c", grid[pos.row][pos.col], grid[right.row][right.col])
		firstPortal, secondPortal = Point{pos.row, pos.col - 1}, Point{pos.row, pos.col + 2}
	}

	if isInBounds(grid, firstPortal) && grid[firstPortal.row][firstPortal.col] == '.' {
		if !isInBounds(grid, secondPortal) {
			return label, Stairs{firstPortal, false}, nil
		}

		return label, Stairs{firstPortal, true}, nil
	} else if isInBounds(grid, secondPortal) && grid[secondPortal.row][secondPortal.col] == '.' {
		if !isInBounds(grid, firstPortal) {
			return label, Stairs{secondPortal, false}, nil
		}

		return label, Stairs{secondPortal, true}, nil
	}

	return "", Stairs{}, errors.New("no label found at specified position")
}

func isInBounds(grid [][]rune, pos Point) bool {
	return pos.row >= 0 && pos.row < len(grid) && pos.col >= 0 && pos.col < len(grid[pos.row])
}

func isInside(ps []Point, p Point) bool {
	for i := range ps {
		if ps[i].row == p.row && ps[i].col == p.col {
			return true
		}
	}

	return false
}

func readInput(filename string) [][]rune {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(bs), "\n")
	lines = lines[:len(lines)-1]

	grid := make([][]rune, len(lines))
	for row, line := range lines {
		grid[row] = make([]rune, len(line))
		for col, ch := range line {
			grid[row][col] = rune(ch)
		}
	}

	return grid
}

func printGrid(grid [][]rune) {
	for row := range grid {
		for col := range grid[row] {
			fmt.Printf("%s", string(grid[row][col]))
		}

		fmt.Println()
	}
}

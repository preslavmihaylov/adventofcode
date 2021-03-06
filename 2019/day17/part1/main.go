package main

import "fmt"

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

func main() {
	initScreen()

	prog := newProgram(initProgram)
	run(prog, inputCallback, outputCallback)

	res := sumAlignmentParameters()
	showScreen()

	fmt.Println(res)
}

func sumAlignmentParameters() int {
	intersections := findIntersections()

	sum := 0
	for _, intersection := range intersections {
		screen[intersection.row][intersection.col] = 'O'
		sum += intersection.row * intersection.col
	}

	return sum
}

func findIntersections() []Point {
	intersections := []Point{}
	for row := range screen {
		for col := range screen[row] {
			if isIntersection(Point{row, col}) {
				intersections = append(intersections, Point{row, col})
			}
		}
	}

	return intersections
}

func isIntersection(p Point) bool {
	up, down, left, right :=
		Point{p.row - 1, p.col}, Point{p.row + 1, p.col}, Point{p.row, p.col - 1}, Point{p.row, p.col + 1}

	if !isInBounds(up) || !isInBounds(right) || !isInBounds(down) || !isInBounds(left) {
		return false
	} else if screen[p.row][p.col] != '#' ||
		screen[up.row][up.col] != '#' ||
		screen[right.row][right.col] != '#' ||
		screen[down.row][down.col] != '#' ||
		screen[left.row][left.col] != '#' {

		return false
	}

	return true
}

func isInBounds(p Point) bool {
	return p.row >= 0 && p.row < len(screen) && p.col >= 0 && p.col < len(screen[row])
}

func inputCallback() int64 {
	return 0
}

func outputCallback(val int64) {
	ch := rune(val)
	if ch == '^' || ch == '>' || ch == 'v' || ch == '<' {
		startingPoint = Point{row, col}
	}

	if ch != '\n' {
		screen[row][col] = rune(val)
		col++
	} else {
		row++
		col = 0
	}

}

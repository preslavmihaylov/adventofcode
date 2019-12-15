package main

import (
	"fmt"
	"os"
)

// MovementState ...
type MovementState int64

// ...
const (
	MovementStateNorth MovementState = iota
	MovementStateSouth               = iota
	MovementStateEast                = iota
	MovementStateWest                = iota
	MovementStateCnt                 = iota
)

// Status ...
type Status int64

// ...
const (
	StatusWall         = iota
	StatusSuccess      = iota
	StatusOxygenSystem = iota
)

// Robot ...
type Robot struct {
	row, col       int
	moveState      MovementState
	steps          []MovementState
	isBacktracking bool
}

// Point ...
type Point struct {
	row, col int
	steps    int
}

var visitedTiles [][]bool
var startingRow, startingCol = rows / 2, cols / 2
var robot = &Robot{row: startingRow, col: startingCol, moveState: MovementStateNorth}
var targetRow, targetCol = -1, -1

func main() {
	initScreen()

	prog := newProgram(initProgram)

	visitedTiles = initVisitedTiles()
	screen[robot.row][robot.col] = 'D'

	run(prog, inputCallback, outputCallback)
}

func timeForOxygenDispersal() int {
	visitedTiles = initVisitedTiles()

	queue := []Point{}
	queue = append(queue, Point{targetRow, targetCol, 0})

	maxSteps := 0
	for len(queue) > 0 {
		p := queue[0]
		queue = queue[1:]
		if p.steps > maxSteps {
			maxSteps = p.steps
		}

		north, south := Point{p.row - 1, p.col, p.steps + 1}, Point{p.row + 1, p.col, p.steps + 1}
		west, east := Point{p.row, p.col - 1, p.steps + 1}, Point{p.row, p.col + 1, p.steps + 1}

		if screen[north.row][north.col] != '#' && !visitedTiles[north.row][north.col] {
			visitedTiles[north.row][north.col] = true
			queue = append(queue, north)
		}

		if screen[east.row][east.col] != '#' && !visitedTiles[east.row][east.col] {
			visitedTiles[east.row][east.col] = true
			queue = append(queue, east)
		}

		if screen[south.row][south.col] != '#' && !visitedTiles[south.row][south.col] {
			visitedTiles[south.row][south.col] = true
			queue = append(queue, south)
		}

		if screen[west.row][west.col] != '#' && !visitedTiles[west.row][west.col] {
			visitedTiles[west.row][west.col] = true
			queue = append(queue, west)
		}
	}

	return maxSteps
}

func inputCallback() int64 {
	switch robot.moveState {
	case MovementStateNorth:
		return 1
	case MovementStateEast:
		return 4
	case MovementStateSouth:
		return 2
	case MovementStateWest:
		return 3
	default:
		panic("no such movement state")
	}
}

func outputCallback(val int64) {
	switch val {
	case StatusWall:
		row, col := nextPosition(robot)
		screen[row][col] = '#'

		robot.moveState, robot.isBacktracking = chooseNextStep(robot)
		visitedTiles[row][col] = true
	case StatusSuccess:
		if targetRow == robot.row && targetCol == robot.col {
			screen[robot.row][robot.col] = 'X'
		} else {
			screen[robot.row][robot.col] = '.'
		}

		robot.row, robot.col = nextPosition(robot)
		screen[robot.row][robot.col] = 'D'

		if !robot.isBacktracking {
			robot.steps = append(robot.steps, robot.moveState)
		}

		robot.moveState, robot.isBacktracking = chooseNextStep(robot)
		visitedTiles[robot.row][robot.col] = true

	case StatusOxygenSystem:
		screen[robot.row][robot.col] = '.'

		robot.row, robot.col = nextPosition(robot)
		screen[robot.row][robot.col] = 'D'
		targetRow, targetCol = robot.row, robot.col

		if !robot.isBacktracking {
			robot.steps = append(robot.steps, robot.moveState)
		}

		robot.moveState, robot.isBacktracking = chooseNextStep(robot)
		visitedTiles[robot.row][robot.col] = true

	default:
		panic("received unknown status code")
	}
}

func chooseNextStep(robot *Robot) (MovementState, bool) {
	if !visitedTiles[robot.row-1][robot.col] {
		return MovementStateNorth, false
	} else if !visitedTiles[robot.row][robot.col+1] {
		return MovementStateEast, false
	} else if !visitedTiles[robot.row+1][robot.col] {
		return MovementStateSouth, false
	} else if !visitedTiles[robot.row][robot.col-1] {
		return MovementStateWest, false
	}

	if len(robot.steps) == 0 {
		fmt.Printf("The time for oxygen dispersal is %d\n", timeForOxygenDispersal())
		os.Exit(0)
	}

	backtrackStep := robot.steps[len(robot.steps)-1]
	robot.steps = robot.steps[:len(robot.steps)-1]

	return oppositeMovementStateOf(backtrackStep), true
}

func oppositeMovementStateOf(state MovementState) MovementState {
	if state == MovementStateNorth {
		return MovementStateSouth
	} else if state == MovementStateSouth {
		return MovementStateNorth
	} else if state == MovementStateEast {
		return MovementStateWest
	} else if state == MovementStateWest {
		return MovementStateEast
	}

	panic("no such movement state")
}

func nextPosition(robot *Robot) (int, int) {
	switch robot.moveState {
	case MovementStateNorth:
		return robot.row - 1, robot.col
	case MovementStateEast:
		return robot.row, robot.col + 1
	case MovementStateSouth:
		return robot.row + 1, robot.col
	case MovementStateWest:
		return robot.row, robot.col - 1
	default:
		panic("no such movement state")
	}
}

func mnemonicOf(state MovementState) string {
	switch state {
	case MovementStateNorth:
		return "north"
	case MovementStateEast:
		return "east"
	case MovementStateSouth:
		return "south"
	case MovementStateWest:
		return "west"
	default:
		panic("unknown movement state")
	}
}

func initVisitedTiles() [][]bool {
	res := make([][]bool, len(screen))
	for row := range screen {
		res[row] = make([]bool, len(screen[row]))
	}

	return res
}

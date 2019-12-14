package main

import (
	"time"
)

// OutputState ...
type OutputState int64

// ...
const (
	OutputStateX      OutputState = iota
	OutputStateY                  = iota
	OutputStateTileID             = iota
	OutputStateCnt                = iota
)

// TileID ...
type TileID int64

// ...
const (
	TileIDEmpty  TileID = iota
	TileIDWall          = iota
	TileIDBlock         = iota
	TileIDPaddle        = iota
	TileIDBall          = iota
)

// Tile ...
type Tile struct {
	x, y   int64
	tileID TileID
}

func main() {
	initScreen()

	prog := newProgram(initProgram)

	// play for free
	prog.instructions[0] = 2

	run(prog, inputCallback, outputCallback)
	showScore()
}

func inputCallback() int64 {
	time.Sleep(20 * time.Millisecond)
	showScreen()
	showScore()

	if ballTile.x < paddleTile.x {
		return -1
	} else if ballTile.x > paddleTile.x {
		return 1
	} else {
		return 0
	}
}

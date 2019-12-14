package main

import (
	"fmt"

	"github.com/buger/goterm"
)

var rows = 25
var cols = 50
var screen [][]rune
var score int64
var outputState = OutputStateX
var tile = Tile{}
var ballTile = Tile{}
var paddleTile = Tile{}

func initScreen() {
	screen = make([][]rune, rows)
	for row := range screen {
		screen[row] = make([]rune, cols)
		for col := range screen[row] {
			screen[row][col] = ' '
		}
	}
}

func showScreen() {
	goterm.Clear()
	for row := range screen {
		goterm.MoveCursor(9, row)
		for col := range screen[row] {
			fmt.Printf("%s", string(screen[row][col]))
		}
		fmt.Println()
	}
}

func showScore() {
	goterm.MoveCursor(rows-5, cols+5)
	fmt.Println("Your score is:", score)
}

func outputCallback(val int64) {
	switch outputState {
	case OutputStateX:
		tile.x = val
	case OutputStateY:
		tile.y = val
	case OutputStateTileID:
		if tile.x != -1 {
			tile.tileID = TileID(val)
			screen[tile.y][tile.x] = getTileImage(tile.tileID)

			if tile.tileID == TileIDBall {
				ballTile = tile
			} else if tile.tileID == TileIDPaddle {
				paddleTile = tile
			}
		} else {
			score = val
		}
	default:
		panic("invalid output state")
	}

	outputState = (outputState + 1) % OutputStateCnt
}

func getTileImage(tileID TileID) rune {
	switch tileID {
	case TileIDEmpty:
		return ' '
	case TileIDWall:
		return '#'
	case TileIDBlock:
		return '='
	case TileIDPaddle:
		return '_'
	case TileIDBall:
		return '*'
	default:
		panic("tile id not found")
	}
}

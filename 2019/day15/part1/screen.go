package main

import "fmt"

var rows = 500
var cols = 500
var screen [][]rune

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
	minVisibleRow, minVisibleCol, maxVisibleRow, maxVisibleCol := rows, cols, 0, 0
	for row := range screen {
		for col := range screen[row] {
			if screen[row][col] != ' ' {
				if minVisibleRow > row {
					minVisibleRow = row
				}

				if maxVisibleRow < row {
					maxVisibleRow = row
				}

				if minVisibleCol > col {
					minVisibleCol = col
				}

				if maxVisibleCol < col {
					maxVisibleCol = col
				}
			}
		}
	}

	for row := range screen {
		anythingVisible := false
		for col := range screen[row] {
			if row >= minVisibleRow && row <= maxVisibleRow &&
				col >= minVisibleCol && col <= maxVisibleCol {

				anythingVisible = true
				fmt.Print(string(screen[row][col]))
			}
		}

		if anythingVisible {
			fmt.Println()
		}
	}
}

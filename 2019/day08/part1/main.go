package main

import (
	"fmt"
	"io/ioutil"
	"math"
)

func main() {
	layerSize := 25 * 6
	input, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	input = input[:len(input)-1]

	zeroesCnt, oneDigitsCnt, twoDigitsCnt := 0, 0, 0
	minZeroes, result := math.MaxInt32, 0
	for i, b := range input {
		if i%layerSize == 0 && i != 0 {
			fmt.Println()

			if zeroesCnt < minZeroes {
				minZeroes = zeroesCnt
				result = oneDigitsCnt * twoDigitsCnt
			}

			zeroesCnt, oneDigitsCnt, twoDigitsCnt = 0, 0, 0
		}

		digit := b - '0'
		if digit == 0 {
			zeroesCnt++
		} else if digit == 1 {
			oneDigitsCnt++
		} else if digit == 2 {
			twoDigitsCnt++
		}

		fmt.Print(digit)
	}

	fmt.Println()
	fmt.Println(result)
}

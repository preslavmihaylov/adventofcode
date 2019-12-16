package main

import (
	"fmt"
	"io/ioutil"
)

var basePattern = []int{0, 1, 0, -1}
var phasesCnt = 100

func main() {
	inputs := readInput("input.txt")

	decodeSignal(inputs, 0)
	fmt.Println(concatArray(inputs[:8]))
}

func decodeSignal(inputs []int, offset int) {
	for phase := 0; phase < phasesCnt; phase++ {
		for digitIndex := offset; digitIndex < len(inputs); digitIndex++ {
			skipsPerPattern := digitIndex + 1

			sum := 0
			for pos := digitIndex; pos < len(inputs); pos++ {
				patternIndex := ((pos + 1) / skipsPerPattern) % len(basePattern)
				sum += inputs[pos] * basePattern[patternIndex]
			}

			inputs[digitIndex] = intAbs(sum) % 10
		}
	}
}

func intAbs(v int) int {
	if v < 0 {
		return -v
	}

	return v
}

func readInput(filename string) []int {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	bs = bs[:len(bs)-1]
	res := []int{}
	for _, b := range bs {
		res = append(res, int(b-'0'))
	}

	return res
}

func concatArray(arr []int) string {
	res := ""
	for _, num := range arr {
		res += string(num + '0')
	}

	return res
}

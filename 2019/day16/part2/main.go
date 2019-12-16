package main

import (
	"fmt"
	"io/ioutil"
)

var basePattern = []int{0, 1, 0, -1}
var phasesCnt = 100
var repeatedInputCnt = 10000

func main() {
	inputs := readInput("input.txt")
	msgOffset := getMessageOffset(inputs)
	fmt.Println(len(inputs), msgOffset)

	decodeSignal(inputs, msgOffset)
	fmt.Println(concatArray(inputs[msgOffset : msgOffset+8]))
}

func getMessageOffset(inputs []int) int {
	res := 0
	for i := 0; i < 7; i++ {
		res = res*10 + inputs[i]
	}

	return res
}

func decodeSignal(inputs []int, offset int) {
	for phase := 0; phase < phasesCnt; phase++ {
		for digitIndex := len(inputs) - 2; digitIndex >= offset; digitIndex-- {
			inputs[digitIndex] = (inputs[digitIndex+1] + inputs[digitIndex]) % 10
		}
	}
}

func readInput(filename string) []int {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	bs = bs[:len(bs)-1]
	initialList := []int{}
	for _, b := range bs {
		initialList = append(initialList, int(b-'0'))
	}

	res := make([]int, repeatedInputCnt*len(initialList))
	for times := 0; times < repeatedInputCnt; times++ {
		for i := range initialList {
			res[times*len(initialList)+i] = initialList[i]
		}
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

package main

import (
	"fmt"
	"io/ioutil"
)

func main() {
	width := 25
	height := 6
	layerSize := width * height

	input, err := ioutil.ReadFile("input.txt")
	if err != nil {
		panic(err)
	}

	input = input[:len(input)-1]
	image := make([]int, layerSize)
	for i := range image {
		image[i] = 2
	}

	for i, b := range input {
		index := i % layerSize
		digit := int(b - '0')

		if image[index] == 2 {
			image[index] = digit
		}
	}

	for row := 0; row < height; row++ {
		for col := 0; col < width; col++ {
			digit := image[row*width+col]
			if digit == 0 {
				fmt.Print(" ")
			} else {
				fmt.Print("*")
			}
		}

		fmt.Println()
	}

}

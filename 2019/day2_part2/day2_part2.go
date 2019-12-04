package main

import "fmt"

func main() {
	targetOutput := 19690720
	for noun := 0; noun <= 99; noun++ {
		for verb := 0; verb <= 99; verb++ {
			program := make([]int, len(initProgram))
			copy(program, initProgram)

			program[1], program[2] = noun, verb
			run(program)

			if program[0] == targetOutput {
				fmt.Println(100*noun + verb)
				return
			}
		}
	}
}

func run(program []int) {
	ip := 0
	for {
		switch program[ip] {
		case 1:
			in1, in2 := program[ip+1], program[ip+2]
			output := program[ip+3]

			program[output] = program[in1] + program[in2]
		case 2:
			in1, in2 := program[ip+1], program[ip+2]
			output := program[ip+3]

			program[output] = program[in1] * program[in2]
		case 99:
			return
		}

		ip += 4
	}
}

var initProgram = []int{
	1, 0, 0, 3, 1, 1, 2, 3, 1, 3, 4, 3, 1, 5, 0, 3, 2, 1, 13, 19, 1, 9, 19, 23, 2, 13, 23, 27, 2, 27, 13, 31, 2, 31, 10, 35, 1, 6, 35, 39, 1, 5, 39, 43, 1, 10, 43, 47, 1, 5, 47, 51, 1, 13, 51, 55, 2, 55, 9, 59, 1, 6, 59, 63, 1, 13, 63, 67, 1, 6, 67, 71, 1, 71, 10, 75, 2, 13, 75, 79, 1, 5, 79, 83, 2, 83, 6, 87, 1, 6, 87, 91, 1, 91, 13, 95, 1, 95, 13, 99, 2, 99, 13, 103, 1, 103, 5, 107, 2, 107, 10, 111, 1, 5, 111, 115, 1, 2, 115, 119, 1, 119, 6, 0, 99, 2, 0, 14, 0,
}

package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type moon struct {
	x, y, z    int
	dx, dy, dz int
}

func (m *moon) String() string {
	return fmt.Sprintf("pos=<x=%d, y=%d, z=%d>, vel=<x=%d, y=%d, z=%d>",
		m.x, m.y, m.z, m.dx, m.dy, m.dz)
}

func main() {
	moons := readInput("input.txt")
	timeStep(moons, 1000)
	fmt.Println(calcTotalEnergy(moons))
}

func readInput(filename string) []*moon {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	moons := []*moon{}
	lines := strings.Split(string(bs), "\n")
	lines = lines[:len(lines)-1]
	for _, line := range lines {
		line = strings.Trim(line, "<>")
		tokens := strings.Split(line, ", ")
		x, err := strconv.Atoi(strings.Split(tokens[0], "=")[1])
		if err != nil {
			panic(err)
		}

		y, err := strconv.Atoi(strings.Split(tokens[1], "=")[1])
		if err != nil {
			panic(err)
		}

		z, err := strconv.Atoi(strings.Split(tokens[2], "=")[1])
		if err != nil {
			panic(err)
		}

		moons = append(moons, &moon{x: x, y: y, z: z})
	}

	return moons
}

func timeStep(moons []*moon, steps int) {
	for step := 0; step < steps; step++ {
		for i := 0; i < len(moons); i++ {
			for j := i + 1; j < len(moons); j++ {
				if i == j {
					continue
				}

				first, second := moons[i], moons[j]
				if first.x > second.x {
					first.dx--
					second.dx++
				} else if first.x < second.x {
					first.dx++
					second.dx--
				}

				if first.y > second.y {
					first.dy--
					second.dy++
				} else if first.y < second.y {
					first.dy++
					second.dy--
				}

				if first.z > second.z {
					first.dz--
					second.dz++
				} else if first.z < second.z {
					first.dz++
					second.dz--
				}
			}
		}

		for i := range moons {
			moons[i].x += moons[i].dx
			moons[i].y += moons[i].dy
			moons[i].z += moons[i].dz
		}
	}
}

func calcTotalEnergy(moons []*moon) int {
	total := 0
	for _, m := range moons {
		pot := intAbs(m.x) + intAbs(m.y) + intAbs(m.z)
		kin := intAbs(m.dx) + intAbs(m.dy) + intAbs(m.dz)
		total += pot * kin
	}

	return total
}

func intAbs(val int) int {
	if val < 0 {
		return -val
	}

	return val
}

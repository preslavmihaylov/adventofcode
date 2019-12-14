package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

type moon struct {
	x, y, z    int64
	dx, dy, dz int64
}

func (m *moon) String() string {
	return fmt.Sprintf("pos=<x=%d, y=%d, z=%d>, vel=<x=%d, y=%d, z=%d>",
		m.x, m.y, m.z, m.dx, m.dy, m.dz)
}

func main() {
	moons := readInput("input.txt")
	steps := timesUntilRepeatedState(moons)
	fmt.Println(steps)
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

		moons = append(moons, &moon{x: int64(x), y: int64(y), z: int64(z)})
	}

	return moons
}

func timesUntilRepeatedState(moons []*moon) int64 {
	slowerMoons := make([]*moon, len(moons))
	fasterMoons := moons
	for i := range moons {
		slowerMoons[i] = &moon{moons[i].x, moons[i].y, moons[i].z, moons[i].dx, moons[i].dy, moons[i].dz}
	}

	slowerStep := int64(0)
	fasterStep := int64(0)
	for {
		makeStep(slowerMoons)
		slowerStep++

		makeStep(fasterMoons)
		makeStep(fasterMoons)
		fasterStep++
		fasterStep++
		if slowerStep%100000000 == 0 {
			fmt.Println(slowerStep)
		}

		if stateHash(slowerMoons) == stateHash(fasterMoons) {
			return slowerStep
		}
	}
}

func makeStep(moons []*moon) {
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

func stateHash(moons []*moon) int64 {
	hash := int64(17)
	for _, m := range moons {
		hash = hash*31 + m.x
		hash = hash*31 + m.y
		hash = hash*31 + m.z
		hash = hash*31 + m.dx
		hash = hash*31 + m.dy
		hash = hash*31 + m.dz
	}

	return hash
}

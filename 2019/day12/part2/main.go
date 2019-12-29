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

func main() {
	moons := readInput("input.txt")
	steps := timesUntilRepeatedState(moons)
	fmt.Println(steps)
}

func timesUntilRepeatedState(moons []*moon) int64 {
	xs, dxs := []int64{}, []int64{}
	ys, dys := []int64{}, []int64{}
	zs, dzs := []int64{}, []int64{}
	for i := range moons {
		xs = append(xs, moons[i].x)
		ys = append(ys, moons[i].y)
		zs = append(zs, moons[i].z)
		dxs = append(dxs, moons[i].dx)
		dys = append(dys, moons[i].dy)
		dzs = append(dzs, moons[i].dz)
	}

	xSteps := stepsUntilLoop(xs, dxs)
	ySteps := stepsUntilLoop(ys, dys)
	zSteps := stepsUntilLoop(zs, dzs)

	return lcm(xSteps, ySteps, zSteps)
}

func stepsUntilLoop(v, dv []int64) int64 {
	seen := map[string]bool{}
	steps := int64(0)
	for !seen[stateHash(v, dv)] {
		seen[stateHash(v, dv)] = true
		for i := 0; i < len(v); i++ {
			for j := i + 1; j < len(v); j++ {
				first, second := v[i], v[j]
				if first > second {
					dv[i]--
					dv[j]++
				} else if first < second {
					dv[i]++
					dv[j]--
				}
			}
		}

		for i := range v {
			v[i] += dv[i]
		}

		steps++
	}

	return steps
}

func lcm(nums ...int64) int64 {
	ans := nums[0]
	for i := 0; i < len(nums); i++ {
		ans = (nums[i] * ans) / gcd(nums[i], ans)
	}

	return ans
}

func gcd(a, b int64) int64 {
	if b == 0 {
		return a
	}

	return gcd(b, a%b)
}

func stateHash(v, dv []int64) string {
	hash := ""
	for i := range v {
		hash += fmt.Sprintf("%d-%d|", v[i], dv[i])
	}

	return hash
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

package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strings"
)

type spaceObject struct {
	parent   string
	children []string
}

func main() {
	objects := readInput("input.txt")
	res := closestPathToSantasOrbit(objects)
	fmt.Println(res)
}

func closestPathToSantasOrbit(objects map[string]*spaceObject) int {
	return closestPath(objects, map[string]bool{}, "SAN", "YOU", 0)
}

func closestPath(objects map[string]*spaceObject, visited map[string]bool, dest, src string, currCnt int) int {
	if src == "" {
		return math.MaxInt32
	} else if visited[src] {
		return math.MaxInt32
	} else if src == dest {
		return currCnt - 2
	}

	visited[src] = true
	currPath, minPath := math.MaxInt32, math.MaxInt32
	currPath = closestPath(objects, visited, dest, objects[src].parent, currCnt+1)
	if minPath > currPath {
		minPath = currPath
	}

	for _, ch := range objects[src].children {
		currPath = closestPath(objects, visited, dest, ch, currCnt+1)
		if minPath > currPath {
			minPath = currPath
		}
	}

	return minPath
}

func readInput(filename string) map[string]*spaceObject {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	results := map[string]*spaceObject{}
	lines := strings.Split(string(bs), "\n")
	for _, line := range lines {
		if line == "" {
			continue
		}

		objs := strings.Split(line, ")")
		parent, child := objs[0], objs[1]

		if _, ok := results[parent]; !ok {
			results[parent] = &spaceObject{parent: "", children: []string{}}
		}

		if _, ok := results[child]; !ok {
			results[child] = &spaceObject{parent: "", children: []string{}}
		}

		results[child].parent = parent
		results[parent].children = append(results[parent].children, child)
	}

	return results
}

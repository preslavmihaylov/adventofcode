package main

import (
	"fmt"
	"io/ioutil"
	"strings"
)

type spaceObject struct {
	parent string
}

func main() {
	objects := readInput("input.txt")

	cnt := 0
	for _, obj := range objects {
		currObj := obj
		for currObj.parent != "" {
			currObj = objects[currObj.parent]
			cnt++
		}
	}

	fmt.Println(cnt)
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
			results[parent] = &spaceObject{parent: ""}
		}

		if _, ok := results[child]; !ok {
			results[child] = &spaceObject{parent: ""}
		}

		results[child].parent = parent
	}

	return results
}

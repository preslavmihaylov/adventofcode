package main

import (
	"fmt"
	"io/ioutil"
	"math"
	"strconv"
	"strings"
)

// Material ...
type Material struct {
	id           string
	quantity     int
	requirements map[string]int
}

var matRequirements = map[string]*Material{}

func main() {
	readInput("input.txt")

	totalOre, _ := totalOreFor("FUEL", 1, map[string]int{})
	fmt.Println(totalOre)
}

func totalOreFor(matID string, quantity int, supply map[string]int) (int, map[string]int) {
	if matID == "ORE" {
		fmt.Printf("Producing %d ORE...\n", quantity)
		return quantity, supply
	}

	if available, ok := supply[matID]; ok {
		fmt.Printf("Reusing leftover %s. leftover=%d, needed=%d\n", matID, available, quantity)
		supply[matID] = intMax(0, available-quantity)
		quantity = intMax(0, quantity-available)

		fmt.Printf("leftover=%d, needed=%d\n", supply[matID], quantity)
	}

	if quantity <= 0 {
		return 0, supply
	}

	fmt.Printf("Starting to produce %d %s...\n", quantity, matID)
	mat := matRequirements[matID]

	bundlesNeeded := int(math.Ceil(float64(quantity) / float64(mat.quantity)))
	productionsCnt := mat.quantity * bundlesNeeded
	leftoverProduction := productionsCnt - quantity
	fmt.Printf("bundles=%d, productions=%d, leftover=%d\n", bundlesNeeded, productionsCnt, leftoverProduction)

	totalOre := 0
	for id, neededCnt := range mat.requirements {
		totalNeeded := neededCnt * bundlesNeeded

		var ore int
		ore, supply = totalOreFor(id, totalNeeded, supply)
		totalOre += ore
	}

	supply[matID] = supply[matID] + leftoverProduction
	fmt.Printf("Producing %d %s. Leftover %d...\n", quantity, matID, supply[matID])

	return totalOre, supply
}

func intMax(a, b int) int {
	if a > b {
		return a
	}

	return b
}

func readInput(filename string) {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(bs), "\n")
	lines = lines[:len(lines)-1]
	for i := range lines {
		tokens := strings.Split(lines[i], " => ")
		reqs := strings.Split(tokens[0], ", ")
		quantity, id := parseMat(tokens[1])
		mat := &Material{
			id:           id,
			quantity:     quantity,
			requirements: map[string]int{},
		}

		for i := range reqs {
			quantity, id := parseMat(reqs[i])
			mat.requirements[id] = quantity
		}

		matRequirements[id] = mat
	}
}

func parseMat(token string) (int, string) {
	toks := strings.Split(token, " ")
	quant, err := strconv.Atoi(toks[0])
	if err != nil {
		panic(err)
	}

	return quant, toks[1]
}

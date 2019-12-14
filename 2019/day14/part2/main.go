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
	quantity     int64
	requirements map[string]int64
}

var matRequirements = map[string]*Material{}

func main() {
	readInput("input.txt")

	oreAvailable, fuelProduced, supply := int64(1000000000000), int64(0), map[string]int64{}
	fuelPerStep := int64(100000)
	for {
		newSupply := map[string]int64{}
		for k, v := range supply {
			newSupply[k] = v
		}

		var oreNeeded int64
		oreNeeded, newSupply = totalOreFor("FUEL", fuelPerStep, newSupply)

		if oreNeeded > oreAvailable && fuelPerStep == 1 {
			break
		}

		if oreNeeded > oreAvailable {
			fuelPerStep /= 2
		} else {
			oreAvailable -= oreNeeded
			fuelProduced += fuelPerStep

			supply = newSupply
		}
	}

	fmt.Println(fuelProduced)
}

func totalOreFor(matID string, quantity int64, supply map[string]int64) (int64, map[string]int64) {
	if matID == "ORE" {
		return quantity, supply
	}

	if available, ok := supply[matID]; ok {
		supply[matID] = intMax(0, available-quantity)
		quantity = intMax(0, quantity-available)
	}

	if quantity <= 0 {
		return 0, supply
	}

	mat := matRequirements[matID]

	bundlesNeeded := int64(math.Ceil(float64(quantity) / float64(mat.quantity)))
	productionsCnt := mat.quantity * bundlesNeeded
	leftoverProduction := productionsCnt - quantity

	totalOre := int64(0)
	for id, neededCnt := range mat.requirements {
		totalNeeded := neededCnt * bundlesNeeded

		var ore int64
		ore, supply = totalOreFor(id, totalNeeded, supply)
		totalOre += ore
	}

	supply[matID] = supply[matID] + leftoverProduction

	return totalOre, supply
}

func intMax(a, b int64) int64 {
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
			requirements: map[string]int64{},
		}

		for i := range reqs {
			quantity, id := parseMat(reqs[i])
			mat.requirements[id] = quantity
		}

		matRequirements[id] = mat
	}
}

func parseMat(token string) (int64, string) {
	toks := strings.Split(token, " ")
	quant, err := strconv.Atoi(toks[0])
	if err != nil {
		panic(err)
	}

	return int64(quant), toks[1]
}

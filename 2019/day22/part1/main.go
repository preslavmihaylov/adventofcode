package main

import (
	"fmt"
	"io/ioutil"
	"strconv"
	"strings"
)

// ShuffleType ...
type ShuffleType int

// ...
const (
	ShuffleTypeCut   ShuffleType = iota
	ShuffleTypeDeal              = iota
	ShuffleTypeStack             = iota
)

// ShuffleCommand ...
type ShuffleCommand struct {
	shuffleType ShuffleType
	arg         int
}

func main() {
	cmds := readInput("input.txt")
	deck := newDeck()
	applyCommands(deck, cmds)
	fmt.Println(findCard2019(deck))
}

func applyCommands(deck []int, cmds []*ShuffleCommand) {
	for _, cmd := range cmds {
		switch cmd.shuffleType {
		case ShuffleTypeCut:
			cutShuffle(deck, cmd.arg)
		case ShuffleTypeDeal:
			dealShuffle(deck, cmd.arg)
		case ShuffleTypeStack:
			stackShuffle(deck)
		default:
			panic("unknown shuffle type")
		}
	}
}

func cutShuffle(deck []int, n int) {
	newDeck := make([]int, len(deck))
	if n > 0 {
		newDeck = append(deck[n:], deck[:n]...)
	} else {
		n = intAbs(n)
		newDeck = append(deck[len(deck)-n:], deck[:len(deck)-n]...)
	}

	copy(deck, newDeck)
}

func dealShuffle(deck []int, n int) {
	newDeck := make([]int, len(deck))

	increment := 0
	for i := 0; i < len(deck); i++ {
		if newDeck[increment] != 0 {
			panic("dealing with increment overrides a position")
		}

		newDeck[increment] = deck[i]
		increment = (increment + n) % len(deck)
	}

	copy(deck, newDeck)
}

func stackShuffle(deck []int) {
	newStack := make([]int, len(deck))
	for i := 0; i < len(deck); i++ {
		newStack[len(newStack)-i-1] = deck[i]
	}

	copy(deck, newStack)
}

func newDeck() []int {
	res := []int{}
	for i := 0; i < 10007; i++ {
		res = append(res, i)
	}

	return res
}

func findCard2019(deck []int) int {
	for i, c := range deck {
		if c == 2019 {
			return i
		}
	}

	return -1
}

func readInput(filename string) []*ShuffleCommand {
	bs, err := ioutil.ReadFile(filename)
	if err != nil {
		panic(err)
	}

	lines := strings.Split(string(bs), "\n")
	lines = lines[:len(lines)-1]

	cmds := []*ShuffleCommand{}
	for _, line := range lines {
		tokens := strings.Split(line, " ")
		cmd := strings.Join(tokens[:len(tokens)-1], " ")
		switch cmd {
		case "deal with increment":
			arg, err := strconv.Atoi(tokens[len(tokens)-1])
			if err != nil {
				panic(err)
			}

			cmds = append(cmds, &ShuffleCommand{ShuffleTypeDeal, arg})
		case "cut":
			arg, err := strconv.Atoi(tokens[len(tokens)-1])
			if err != nil {
				panic(err)
			}

			cmds = append(cmds, &ShuffleCommand{ShuffleTypeCut, arg})
		case "deal into new":
			cmds = append(cmds, &ShuffleCommand{ShuffleTypeStack, 0})
		default:
			panic("unknown command")
		}
	}

	return cmds
}

func intAbs(a int) int {
	if a < 0 {
		return -a
	}

	return a
}

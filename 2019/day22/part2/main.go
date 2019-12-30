package main

import (
	"fmt"
	"io/ioutil"
	"math/big"
	"strconv"
	"strings"
)

var deckSize = big.NewInt(119315717514047)
var shufflesCnt = big.NewInt(101741582076661)

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
	arg         int64
}

func main() {
	cmds := readInput("input.txt")

	reverseShuffle := repeatOp(ReverseShuffleOp(cmds), shufflesCnt)
	reverseRes := applyOp(2020, reverseShuffle)
	fmt.Println(reverseRes)
}

// Operation ...
type Operation func() (*big.Int, *big.Int)

func repeatOp(op Operation, times *big.Int) Operation {
	if times.Int64() == 1 {
		return op
	}

	// if times % 2 == 0
	if new(big.Int).Mod(times, big.NewInt(2)).Int64() == 0 {
		// op := repeatOp(op, times/2)
		op := repeatOp(op, new(big.Int).Div(times, big.NewInt(2)))
		return combineOp(op, op)
	}

	// return combineOp(op, repeatOp(op, times-1))
	return combineOp(op, repeatOp(op, new(big.Int).Sub(times, big.NewInt(1))))
}

func combineOp(op1, op2 Operation) Operation {
	if op1 == nil {
		return op2
	} else if op2 == nil {
		return op1
	}

	a1, b1 := op1()
	a2, b2 := op2()
	return func() (*big.Int, *big.Int) {
		res := new(big.Int).Mul(a2, b1)
		res.Add(res, b2)

		// return modulo(a1*a2, deckSize), modulo(a2*b1 + b2, deckSize)
		return modulo(new(big.Int).Mul(a1, a2), deckSize), modulo(res, deckSize)
	}
}

func applyOp(pos int64, op Operation) *big.Int {
	a, b := op()
	res := new(big.Int).Mul(a, big.NewInt(pos))
	res.Add(res, b)

	// return modulo(a*pos + b, deckSize)
	return modulo(res, deckSize)
}

// ShuffleOp ...
func ShuffleOp(cmds []*ShuffleCommand) Operation {
	curr := Operation(nil)
	for _, cmd := range cmds {
		switch cmd.shuffleType {
		case ShuffleTypeCut:
			curr = combineOp(curr, CutNOp(big.NewInt(cmd.arg), deckSize))
		case ShuffleTypeDeal:
			curr = combineOp(curr, DealWithIncNOp(big.NewInt(cmd.arg)))
		case ShuffleTypeStack:
			curr = combineOp(curr, DealStackOp(deckSize))
		default:
			panic("unknown shuffle type")
		}
	}

	return curr
}

// ReverseShuffleOp ...
func ReverseShuffleOp(cmds []*ShuffleCommand) Operation {
	curr := Operation(nil)
	for i := len(cmds) - 1; i >= 0; i-- {
		cmd := cmds[i]
		switch cmd.shuffleType {
		case ShuffleTypeCut:
			curr = combineOp(curr, ReverseCutNOp(big.NewInt(cmd.arg), deckSize))
		case ShuffleTypeDeal:
			curr = combineOp(curr, ReverseDealWithIncNOp(big.NewInt(cmd.arg), deckSize))
		case ShuffleTypeStack:
			curr = combineOp(curr, ReverseDealStackOp(deckSize))
		default:
			panic("unknown shuffle type")
		}
	}

	return curr
}

// DealStackOp ...
func DealStackOp(length *big.Int) Operation {
	return func() (*big.Int, *big.Int) {
		// return -1, length-1
		return big.NewInt(-1), new(big.Int).Sub(length, big.NewInt(1))
	}
}

// ReverseDealStackOp ...
func ReverseDealStackOp(length *big.Int) Operation {
	return func() (*big.Int, *big.Int) {
		// return -1, length-1
		return big.NewInt(-1), new(big.Int).Sub(length, big.NewInt(1))
	}
}

// CutNOp ...
func CutNOp(n, length *big.Int) Operation {
	return func() (*big.Int, *big.Int) {
		// return 1, length-n
		return big.NewInt(1), new(big.Int).Sub(length, n)
	}
}

// ReverseCutNOp ...
func ReverseCutNOp(n, length *big.Int) Operation {
	return func() (*big.Int, *big.Int) {
		// return 1, n-length
		return big.NewInt(1), new(big.Int).Sub(n, length)
	}
}

// DealWithIncNOp ...
func DealWithIncNOp(n *big.Int) Operation {
	return func() (*big.Int, *big.Int) {
		// return n, 0
		return n, big.NewInt(0)
	}
}

// ReverseDealWithIncNOp ...
func ReverseDealWithIncNOp(n, length *big.Int) Operation {
	return func() (*big.Int, *big.Int) {
		a := new(big.Int).ModInverse(n, length)

		// return modinv(n, length), 0
		return a, big.NewInt(0)
	}
}

func modulo(a, mod *big.Int) *big.Int {
	if a.Int64() >= 0 {
		// return a % mod
		return new(big.Int).Mod(a, mod)
	}

	// making % operator work as 'modulo' for negative numbers
	// e.g. -1 % 5 = 4

	// return mod - (-a % mod)
	return new(big.Int).Sub(mod,
		new(big.Int).Mod(
			new(big.Int).Mul(big.NewInt(-1), a), mod))
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

			cmds = append(cmds, &ShuffleCommand{ShuffleTypeDeal, int64(arg)})
		case "cut":
			arg, err := strconv.Atoi(tokens[len(tokens)-1])
			if err != nil {
				panic(err)
			}

			cmds = append(cmds, &ShuffleCommand{ShuffleTypeCut, int64(arg)})
		case "deal into new":
			cmds = append(cmds, &ShuffleCommand{ShuffleTypeStack, 0})
		default:
			panic("unknown command")
		}
	}

	return cmds
}

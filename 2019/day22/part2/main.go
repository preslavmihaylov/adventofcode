package main

import (
	"fmt"
	"io/ioutil"
	"runtime"
	"strconv"
	"strings"
	"sync"
)

var deckSize = int64(119315717514047)
var shufflesCnt = int64(101741582076661)

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

	op := repeatOp(ShuffleOp(cmds), shufflesCnt)
	fmt.Println(findPos2020(op))
}

func findPos2020(op Operation) int64 {
	resultC, quitC := make(chan int64, 1), make(chan struct{}, 1)
	procs := int64(runtime.NumCPU())
	fmt.Printf("starting %d goroutines...\n", procs)

	var wg sync.WaitGroup
	for proc := int64(0); proc < procs; proc++ {
		chunk := deckSize / procs
		start, end := proc*chunk, proc*chunk+chunk
		if proc == procs-1 {
			end = deckSize
		}

		wg.Add(1)
		go func(proc, start, end int64, resultC chan int64) {
			defer wg.Done()

			for i := start; i < end; i++ {
				select {
				case <-quitC:
					break
				default:
				}

				percent := float64(i-start) / float64(end-start) * 100
				if percent >= 10 && percent < 11 {
					fmt.Printf("proc %d is at %f%%\n", proc, percent)
				}

				res := applyOp(i, op)
				if res == 2020 {
					resultC <- i
					break
				}
			}
		}(proc, start, end, resultC)
	}

	var res int64
	select {
	case res = <-resultC:
		quitC <- struct{}{}
	}

	wg.Wait()
	return res
}

// Operation ...
type Operation func() (int64, int64)

func repeatOp(op Operation, times int64) Operation {
	if times == 1 {
		return op
	}

	if times%2 == 0 {
		op := repeatOp(op, times/2)
		return combineOp(op, op)
	}

	return combineOp(op, repeatOp(op, times-1))
}

func combineOp(op1, op2 Operation) Operation {
	if op1 == nil {
		return op2
	} else if op2 == nil {
		return op1
	}

	a1, b1 := op1()
	a2, b2 := op2()
	return func() (int64, int64) {
		return (a1 * a2) % deckSize, (a2*b1 + b2) % deckSize
	}
}

func applyOp(pos int64, op Operation) int64 {
	a, b := op()
	return (a*pos + b) % deckSize
}

// ShuffleOp ...
func ShuffleOp(cmds []*ShuffleCommand) Operation {
	curr := Operation(nil)
	for _, cmd := range cmds {
		switch cmd.shuffleType {
		case ShuffleTypeCut:
			curr = combineOp(curr, CutNOp(cmd.arg, deckSize))
		case ShuffleTypeDeal:
			curr = combineOp(curr, DealWithIncNOp(cmd.arg))
		case ShuffleTypeStack:
			curr = combineOp(curr, DealStackOp(deckSize))
		default:
			panic("unknown shuffle type")
		}
	}

	return curr
}

// DealStackOp ...
func DealStackOp(length int64) Operation {
	return func() (int64, int64) {
		return -1, length - 1
	}
}

// CutNOp ...
func CutNOp(n, length int64) Operation {
	return func() (int64, int64) {
		return 1, length - n
	}
}

// DealWithIncNOp ...
func DealWithIncNOp(n int64) Operation {
	return func() (int64, int64) {
		return n, 0
	}
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

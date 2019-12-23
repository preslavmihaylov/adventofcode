package main

import (
	"fmt"
	"sync"
)

// Packet ...
type Packet struct {
	Addr, X, Y int64
}

// PacketReadState ...
type PacketReadState int

// ...
const (
	PacketReadX PacketReadState = iota
	PacketReadY                 = iota
)

// PacketSendState ...
type PacketSendState int

// ...
const (
	PacketSendAddr PacketSendState = iota
	PacketSendX                    = iota
	PacketSendY                    = iota
)

func newComputer(mutex *sync.Mutex, instructions []int64) *Computer {
	return &Computer{
		mutex,
		newProgram(instructions),
		false, Packet{0, 0, 0}, PacketReadX, PacketSendAddr}
}

// Computer ...
type Computer struct {
	mutex *sync.Mutex

	program           *program
	addressAssigned   bool
	transmittedPacket Packet
	PacketReadState
	PacketSendState
}

var computersCnt = int64(50)
var computers []*Computer
var buffers [][]Packet

func main() {
	computers = make([]*Computer, computersCnt)
	buffers = make([][]Packet, computersCnt)
	mux := &sync.Mutex{}

	var wg sync.WaitGroup
	for i := 0; i < int(computersCnt); i++ {
		computers[i] = newComputer(mux, initProgram)

		wg.Add(1)
		go run(computers[i].program, inputCallbackFor(i), outputCallbackFor(i))
	}

	wg.Wait()
}

func inputCallbackFor(compID int) func() int64 {
	return func() int64 {
		comp := computers[compID]

		if !comp.addressAssigned {
			comp.addressAssigned = true
			return int64(compID)
		}

		if len(buffers[compID]) == 0 {
			return -1
		}

		buffer := buffers[compID]
		packet := buffer[0]

		comp.mutex.Lock()
		defer comp.mutex.Unlock()

		switch comp.PacketReadState {
		case PacketReadX:
			comp.PacketReadState = PacketReadY
			return packet.X
		case PacketReadY:
			comp.PacketReadState = PacketReadX
			buffers[compID] = buffers[compID][1:]
			return packet.Y
		default:
			panic("invalid state for input callback")
		}
	}
}

func outputCallbackFor(compID int) func(int64) {
	return func(val int64) {
		comp := computers[compID]

		comp.mutex.Lock()
		defer comp.mutex.Unlock()

		switch comp.PacketSendState {
		case PacketSendAddr:
			comp.PacketSendState = PacketSendX
			comp.transmittedPacket.Addr = val
		case PacketSendX:
			comp.PacketSendState = PacketSendY
			comp.transmittedPacket.X = val
		case PacketSendY:
			comp.PacketSendState = PacketSendAddr
			comp.transmittedPacket.Y = val

			destAddr := comp.transmittedPacket.Addr
			if destAddr < computersCnt {
				fmt.Printf("transmitting packet %v to %d.\n", comp.transmittedPacket, destAddr)
				buffers[destAddr] = append(buffers[destAddr], comp.transmittedPacket)
			} else {
				fmt.Printf("attempting to transmit packet %v to address %d\n",
					comp.transmittedPacket, destAddr)
			}
		}
	}
}

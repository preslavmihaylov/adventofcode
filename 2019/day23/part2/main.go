package main

import (
	"fmt"
	"sync"
	"time"
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

func newComputer(mutex *sync.Mutex, quit chan struct{}, instructions []int64) *Computer {
	return &Computer{
		mutex, quit,
		newProgram(instructions),
		false, Packet{0, 0, 0}, PacketReadX, PacketSendAddr}
}

// Computer ...
type Computer struct {
	mutex *sync.Mutex
	quit  chan struct{}

	program           *program
	addressAssigned   bool
	transmittedPacket Packet
	PacketReadState
	PacketSendState
}

var computersCnt = int64(50)
var computers []*Computer
var buffers [][]Packet

// NATPacket ...
var NATPacket Packet
var yValuesSent = map[int64]int64{}

func main() {
	computers = make([]*Computer, computersCnt)
	buffers = make([][]Packet, computersCnt)
	mux := &sync.Mutex{}

	var wg sync.WaitGroup
	quit := make(chan struct{}, 1)
	for i := 0; i < int(computersCnt); i++ {
		computers[i] = newComputer(mux, quit, initProgram)

		wg.Add(1)
		go run(computers[i].program, inputCallbackFor(i), outputCallbackFor(i))
	}

	ticker := time.NewTicker(1 * time.Second)
	for {
		isClosed := false
		select {
		case <-ticker.C:
			NATProcess(quit)
		case <-quit:
			isClosed = true
			ticker.Stop()

			break
		}

		if isClosed {
			break
		}
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
				fmt.Printf("transmitting packet %v to NAT\n", comp.transmittedPacket)
				NATPacket = comp.transmittedPacket
			}
		}
	}
}

// NATProcess ...
func NATProcess(quit chan struct{}) {
	allIdle := true
	for i := range computers {
		if len(buffers[i]) > 0 {
			allIdle = false
		}
	}

	if allIdle {
		fmt.Printf("Waking up everyone with packet %v\n", NATPacket)

		yValuesSent[NATPacket.Y] = yValuesSent[NATPacket.Y] + 1
		if yValuesSent[NATPacket.Y] == 2 {
			fmt.Printf("Y Value %d sent twice in a roll...\n", NATPacket.Y)
			close(quit)

			return
		}

		buffers[0] = append(buffers[0], NATPacket)
	}
}

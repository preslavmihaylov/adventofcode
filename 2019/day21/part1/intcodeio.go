package main

// InputState ...
type InputState int

// ...
const (
	InputStateInit     InputState = iota
	InputStateReading             = iota
	InputStateFinished            = iota
)

const maxASCII = 256

var inputState = InputStateInit
var inputBuff string
var outputBuff string

func inputCallback() int64 {
	switch inputState {
	case InputStateInit:
		fallthrough
	case InputStateFinished:
		inputState = InputStateReading
		inputBuff = inputLineCallback()

		fallthrough
	case InputStateReading:
		if inputBuff == "" {
			inputState = InputStateFinished

			return int64('\n')
		}

		res := inputBuff[0]
		inputBuff = inputBuff[1:]

		return int64(res)

	default:
		panic("unknown input state")
	}
}

func outputCallback(val int64) {
	if val > maxASCII {
		resultCallback(val)

		return
	}

	if val == int64('\n') {
		outputLineCallback(outputBuff)
		outputBuff = ""

		return
	}

	outputBuff += string(rune(val))
}

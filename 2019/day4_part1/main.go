package main

import (
	"fmt"
	"strconv"
)

func main() {
	cnt := 0
	for i := 264793; i < 803935; i++ {
		if meetsCriteria(strconv.Itoa(i)) {
			fmt.Println(i)
			cnt++
		}
	}

	fmt.Println(cnt)
}

func meetsCriteria(password string) bool {
	hasDouble := false
	biggestDigit := 0
	for i := range password {
		if i < len(password)-1 && password[i] == password[i+1] {
			hasDouble = true
		}

		digit, err := strconv.Atoi(string(password[i]))
		if err != nil {
			panic(err)
		}

		if biggestDigit > digit {
			return false
		}

		biggestDigit = digit
	}

	return hasDouble
}

package main // The file containing the main() function must also be the main package

import (
	"fmt"     // Gives us IO functions like printf and scanf
	"math"    // Gives us math functions like sqrt and floor
	"os"      // Gives us command line argument functions
	"strconv" // Gives us string to int conversions
	"sync"    // Gives us useful multi-threading syncronisation functions
)

var primeList []int // Pointer variable accessible to anything in this file

// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
func findFactors(testNum int, verbose bool) bool {
	testLimit := int(math.Floor(math.Sqrt(float64(testNum)))) // Local constant variable, the := operator means implicitly infer the data type
	isPrime := true

	if testNum <= 3 {
		isPrime = (testNum > 1)
		if verbose {
			fmt.Printf("Special case %d", testNum) // %d means print an integer
		}
	} else {
		for i := 2; i <= 3; i++ { // Test for divisibility by 2 and 3
			if (testNum % i) == 0 {
				isPrime = false
				if verbose {
					fmt.Printf("divides by %d", i)
				}
			}
		}
	}

	if isPrime == true {
		for divisor := 5; divisor <= testLimit; divisor += 6 { // Loop from divisor = 5 to testLimit (inclusive), increment by 6
			if (testNum % divisor) == 0 { // Test if it divides by the divisor (i.e. 6k - 1)
				if verbose {
					fmt.Printf("divides by %d", divisor)
				}
				isPrime = false
			}

			if (testNum % (divisor + 2)) == 0 { // Test if it divides by the divisor + 2 (i.e. 6k + 1)
				if verbose {
					fmt.Printf("divides by %d", divisor+2)
				}
				isPrime = false
			}
		}
	}
	return isPrime
}

// Helper function for calculating all prime numbers up to maxNumber
//
func primeListTest(maxNumber int) int {
	var numPrimes int = 0
	primeList = make([]int, maxNumber) // Dynamic memory allocation & automatically initializes to 0

	var work sync.WaitGroup // A waitgroup is the main way we can make a parallel section of code
	work.Add(maxNumber)     // Tell the waitgroup how many iterations we're about to do

	for i := 1; i <= maxNumber; i++ { // Loop from i = 1 to maxNumber (inclusive), increment by 1
		go func(i int) { // Uses a goroutine to spawn a thread to run this chunk of code with it's own copy of the i variable
			defer work.Done()                  // defer means run only when this function finishes, work.Done() tells the WaitGroup it's done
			if findFactors(i, false) == true { // Is this number (i) prime?
				primeList[i-1] = i // Arrays start at 0 in Go
			}
		}(i)
	}

	work.Wait() // Waits here until Done() has been called maxNumber of times

	for i := 0; i < maxNumber; i++ { // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
		if primeList[i] != 0 {
			primeList[numPrimes] = primeList[i]
			numPrimes++ // Count up the number of primes we found
		}
	}
	return numPrimes
}

// main is the default name for the starting point of a program in Go
//
func main() {
	maxNumber, convError := strconv.Atoi(os.Args[1]) // Atoi = Ascii TO Integer, Args[0] will be the name of the executable, the first argument is Args[1]

	if convError == nil {
		numPrimes := primeListTest(maxNumber) // Calculates all prime numbers up to maxNumber
		fmt.Printf("Generated %d primes, Largest was: %d \n", numPrimes, primeList[numPrimes-1])
	}
}

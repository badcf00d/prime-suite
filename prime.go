package main // The file containing the main() function must also be the main package

// In Go you can embed C code in comments with import "C" below it, pretty cool huh?

/*
#include <time.h>

static long long cpuClock() {
    struct timespec t;
    clock_gettime(CLOCK_THREAD_CPUTIME_ID, &t);
    return (t.tv_sec * 1e9) + t.tv_nsec;
}
*/
import "C"

import (
	"fmt"
	"math"
	"time"
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

	return isPrime
}

// Helper function for calculating all prime numbers up to maxNumber
//
func primeListTest(maxNumber int) int {
	var numPrimes int = 0
	primeList = make([]int, maxNumber) // Dynamic memory allocation & automatically initializes to 0

	for i := 1; i <= maxNumber; i++ { // Loop from i = 1 to maxNumber (inclusive), increment by 1
		if findFactors(i, false) == true { // Is this number (i) prime?
			primeList[i-1] = i // Arrays start at 0 in C
		}
	}

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
	var maxNumber int

	fmt.Printf("Generate all primes up to: ")
	fmt.Scanf("%d", &maxNumber) // Read from stdin as a number (%d)

	sysStart := time.Now()                // Get the system time, this will be the apparent runtime
	cpuStart := C.cpuClock()              // Get the cpu time, this will be the cpu runtime
	numPrimes := primeListTest(maxNumber) // Calculates all prime numbers up to maxNumber
	cpuFinish := C.cpuClock()             // Get finish cpu time
	apparentTime := time.Since(sysStart)  // Get the finishing system time

	cpuTime := float64(cpuFinish-cpuStart) / 1e9 // Convert nanoseconds to seconds

	fmt.Printf("Generated %d primes, Largest was: %d \n", numPrimes, primeList[numPrimes-1])
	fmt.Printf("Apparent time = %7.3f seconds\n", apparentTime.Seconds())
	fmt.Printf("CPU time = %12.6f seconds\n", cpuTime)
}

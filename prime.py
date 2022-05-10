#!/bin/python3
import math                                                                     # Gives us math functions like sqrt and floor
import multiprocessing, itertools                                               # Gives us multithreading related functions
import sys                                                                      # Gives us command line argument functions
import array as arr                                                             # Gives us arrays


# Factor test by trial division using the 6k +- 1 optimisation, this
# means that factors of factors will not be displayed, i.e. if the test
# number is a factor of 2, it will not show 4, 6, 8 etc.
#
def findFactors(testNum, verbose):
    isPrime = True
    testLimit = math.floor(math.sqrt(testNum))                                  # Local constant variable

    if (testNum <= 3):
        isPrime = (testNum > 1)
        if (verbose): print("Special case %d" % (testNum))
    else:
        for i in range(2, 4):                                                   # Test for divisibility by 2 and 3
            if ((testNum % i) == 0):
                isPrime = False
                if (verbose): print("%d divides by %d" % (testNum, i))

    if isPrime == True:
        for divisor in range(5, testLimit + 1, 6):
            if ((testNum % divisor) == 0):                                      # Test if it divides by the divisor (i.e. 6k - 1)
                if (verbose): print("%d divides by %d" % (testNum, divisor))
                isPrime = False
            if ((testNum % (divisor + 2)) == 0):                                # Test if it divides by the divisor + 2 (i.e. 6k + 1)
                if (verbose): print("%d divides by %d" % (testNum, divisor + 2))
                isPrime = False

    if isPrime == True:
        return testNum
    else:
        return 0


# Helper function for calculating all prime numbers up to maxNumber
#
def primeListTest(maxNumber):
    numberList = arr.array('I', range(1, maxNumber + 1))                        # Prepares an array from 1 to maxNumber (inclusive)
    chunkSize = min((maxNumber / multiprocessing.cpu_count()), 10000)           # From experimentation using chunks over 10000 significantly hurts performance
    numPrimes = 0

    with multiprocessing.Pool(multiprocessing.cpu_count()) as p:                # Spawns multiple instances of Python to compute parts of the loop in parralel
        # starmap allows us to pass an iterable with multiple elements so we can
        # make use of the verbose argument, if we removed that we could write
        # primeList = p.map(findFactors, numberList, chunksize=chunkSize) which is ~10% faster
        primeList = p.starmap(findFactors, zip(numberList, itertools.repeat(False)), chunksize=chunkSize)

    for i in primeList:                                                         # This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
        if (i != 0):
            primeList[numPrimes] = i
            numPrimes += 1

    return primeList, numPrimes


# Called by the slightly odd if statement below
#
def main():
    maxNumber = int(sys.argv[1])                                                # argv[0] will be the py file, the first argument is argv[1]
    primeList, numPrimes = primeListTest(maxNumber)
    print("Generated %d primes, Largest was: %d " % (numPrimes, primeList[numPrimes - 1]))


# This will be the start of the program as it's the first bit that's
# not part of another definition.
#
# When we call this script from the command line, __name__ will be "__main__",
# if this is being used as a library from another python script, it will be
# something different, so main() won't get called.
#
if __name__ == "__main__":
    main()
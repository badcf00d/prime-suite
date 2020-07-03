import time, math                                                               # Gives us system timing functions and math functions like sqrt and floor
import multiprocessing, itertools                                               # Gives us multithreading related functions 
import sys                                                                      # Gives us command line argument functions

primeList = [0]                                                                 # Global variable that is a list [] of integers



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

    for divisor in range(5, testLimit + 1, 6):
        if ((testNum % divisor) == 0):                                          # Test if it divides by the divisor (i.e. 6k - 1)
            if (verbose): print("%d divides by %d" % (testNum, divisor))
            isPrime = False
        if ((testNum % (divisor + 2)) == 0):                                    # Test if it divides by the divisor + 2 (i.e. 6k + 1)
            if (verbose): print("%d divides by %d" % (testNum, divisor + 2))
            isPrime = False

    return isPrime



# Helper function for calculating all prime numbers up to maxNumber
#
def primeListTest(maxNumber):
    global primeList                                                            # Specifies that we want to use the global variable rather than make a new one with the same name

    numProcessors = multiprocessing.cpu_count()                                 # Gets the number of threads of the CPU
    numberList = range(1, maxNumber + 1)                                        # Prepares a list from 0 to maxNumber (inclusive)
    primeList = [0] * maxNumber                                                 # This isn't quite the same as dynamic memory allocation, but creates an array of maxNumber elements
    numPrimes = 0                                                               # Arrays start at 0 in Python

    with multiprocessing.Pool(numProcessors) as p:                              # Spawns multiple instances of Python to compute parts of the loop in parralel
        for i, isPrime in zip(numberList, p.starmap(findFactors, \
                          zip(numberList, itertools.repeat(False)))):           # zip makes a single list out of separate arguments, p.starmap calls findFactors with those arguments
            if (isPrime == True):
                primeList[numPrimes] = i                                        # Arrays start at 0 in Python
                numPrimes += 1                                                  # We don't need mutex locks here because they are completely separate processes with their own memory

    return numPrimes




# Called by the slightly odd if statement below
#
def main():
    maxNumber = int(sys.argv[1])                                                # argv[0] will be the py file, the first argument is argv[1]
    numPrimes = primeListTest(maxNumber)
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
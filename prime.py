import time, math
import concurrent.futures

primeList = [0]


def findFactorsLoop(testNum, divisor, verbose):
    isPrime = True
    
    if ((testNum % divisor) == 0):                                  # Test if it divides by the divisor (i.e. 6k - 1)
        if (verbose): print("%d divides by %d" % (testNum, divisor))
        isPrime = False
    if ((testNum % (divisor + 2)) == 0):                    # Test if it divides by the divisor + 2 (i.e. 6k + 1)
        if (verbose): print("%d divides by %d" % (testNum, divisor + 2))
        isPrime = False
    
    return isPrime


def findFactors(testNum, verbose):
    isPrime = True
    testLimit = math.floor(math.sqrt(testNum))                          # Local constant variable

    if (testNum <= 3):
        isPrime = (testNum > 1)    
        if (verbose): print("Special case %d" % (testNum))                
    else: 
        for i in range(2, 4):                                    # Test for divisibility by 2 and 3
            if ((testNum % i) == 0): 
                isPrime = False
                if (verbose): print("%d divides by %d" % (testNum, i))

    for divisor in range(5, testLimit + 1, 6):
        if ((testNum % divisor) == 0):                                  # Test if it divides by the divisor (i.e. 6k - 1)
            if (verbose): print("%d divides by %d" % (testNum, divisor))
            isPrime = False
        if ((testNum % (divisor + 2)) == 0):                    # Test if it divides by the divisor + 2 (i.e. 6k + 1)
            if (verbose): print("%d divides by %d" % (testNum, divisor + 2))
            isPrime = False

    return isPrime



def primeListTest(maxNumber):
    numPrimes = 0

    global primeList
    primeList = [0] * maxNumber

    for i in range(0, maxNumber + 1):                                                                
        isPrime = findFactors(i, False)
        if (isPrime == True):
            primeList[numPrimes] = i                                    # Arrays start at 0 in C
            numPrimes += 1
    return numPrimes



def main():
    maxNumber = int(input("Generate all primes up to: "))

    sysStart = time.perf_counter()
    cpuStart = time.process_time()
    numPrimes = primeListTest(maxNumber)
    cpuFinish = time.process_time()
    sysFinish = time.perf_counter()

    apparentTime = sysFinish - sysStart
    cpuTime = cpuFinish - cpuStart

    print("Generated %d primes, Largest was: %d " % (numPrimes, primeList[numPrimes - 1]))
    print("Apparent time = %7.3f seconds\n" % (apparentTime))
    print("CPU time = %12.6f seconds\n" % (cpuTime))

if __name__ == "__main__":
    main()
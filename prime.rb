require 'parallel'                                                      # Gives us access to the Parallel module



# Factor test by trial division using the 6k +- 1 optimisation, this
# means that factors of factors will not be displayed, i.e. if the test
# number is a factor of 2, it will not show 4, 6, 8 etc.
#
def findFactors(testNum, verbose)
    testLimit = Math.sqrt(testNum).floor()                              # Local variable
    isPrime = true

    if testNum <= 3
        isPrime = (testNum > 1);
        if verbose
            puts "Special case %d" % [testNum]                          # %d means print an integer
        end
    else
        for i in 2..3                                                   # Test for divisibility by 2 and 3
            if ((testNum % i) == 0)
                isPrime = false
                if verbose
                    puts "divides by %d" % [i]
                end
            end
        end
    end

    if isPrime == true
        for divisor in (5..testLimit).step(6)                           # Loop from divisor = 5 to testLimit (inclusive), increment by 6
            if ((testNum % divisor) == 0)                               # Test if it divides by the divisor (i.e. 6k - 1)
                if verbose
                    puts "divides by %d" % [divisor]
                end
                isPrime = false
            end

            if ((testNum % (divisor + 2)) == 0)                         # Test if it divides by the divisor + 2 (i.e. 6k + 1)
                if verbose
                    puts "divides by %d" % [divisor + 2]
                end
                isPrime = false
            end
        end
    end

    return isPrime
end



# Helper function for calculating all prime numbers up to maxNumber
#
def primeListTest(maxNumber)
    numPrimes = 0
    primeList = Array.new                                               # An empty array, it's not neccesary to explicitly allocate memory

    primeList = Parallel.map(0..maxNumber) { |i|                        # You need to get the return value from Parallel or primeList won't get set to anything
        if findFactors(i, false) == true
            primeList[i - 1] = i                                        # This is a local variable to this Parallel function
        end
    }

    for i in 0..(maxNumber - 1)                                         # This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
        if primeList[i] != nil                                          # If an element of an array has not been set, it will be nil
            primeList[numPrimes] = primeList[i]
            numPrimes += 1                                              # Count up the number of primes we found
        end
    end

    return numPrimes, primeList                                         # Ruby allows multiple return values
end



# This will be the starting point as it is not part of a definition
#
maxNumber = ARGV[0].to_i                                                # Take the first command line argument and convert it to an integer
numPrimes, primeList = primeListTest(maxNumber)                         # Ruby allows multiple return values
puts "Generated %d primes, Largest was: %d" % [numPrimes, primeList[numPrimes - 1]]

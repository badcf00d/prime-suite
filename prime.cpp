#include <iostream>                                                     // Gives us printf
#include <vector>                                                       // Gives us the vector data type
#include <cmath>                                                        // Gives us sqrt and floor


class prime                                                             // We've got classes we may aswell use them right?
{
    public:                                                             // Things declared under public are accessible to things using the prime class
        std::vector<int> primeList;                                     // This doesn't actually declare any memory, it's just a placeholder for our variable
        int primeListTest(const int maxNumber);                         // A function prototype, the definition of this function will be called prime::primeListTest
    private:                                                            // Things declared under private are only accessible to things within the prime class
        bool findFactors(const int testNum, bool verbose);              // This is a private function so only available within this class, not, for example, in main()
};




// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
// The :: here means this is the definition of the findFactors function
// prototype in the prime class, not a standalone function.
//
bool prime::findFactors(const int testNum, bool verbose)
{
    int const testLimit = (int) floor(sqrt((double) testNum));          // Local constant variable
    bool isPrime = true;

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) printf("Special case %d\n", testNum);                // %d means print an integer
    }
    else
    {
        for (int i = 2; i <= 3; i++)                                    // Test for divisibility by 2 and 3
        {
            if ((testNum % i) == 0)
            {
                isPrime = false;
                if (verbose) printf("divides by %d\n", i);
            }
        }
    }

    if (isPrime)
    {
        for (int divisor = 5; divisor <= testLimit; divisor += 6)       // Loop from divisor = 5 to testLimit (inclusive), increment by 6
        {
            if ((testNum % divisor) == 0)                               // Test if it divides by the divisor (i.e. 6k - 1)
            {
                if (verbose) printf("divides by %d\n", divisor);
                isPrime = false;
            }

            if ((testNum % (divisor + 2)) == 0)                         // Test if it divides by the divisor + 2 (i.e. 6k + 1)
            {
                if (verbose) printf("divides by %d\n", divisor + 2);
                isPrime = false;
            }
        }
    }
    return isPrime;
}




// Helper function for calculating all prime numbers up to maxNumber
//
int prime::primeListTest(const int maxNumber)
{
    int numPrimes = 0;
    primeList.resize(maxNumber, 0);                                     // Initialises our primeList with maxNumber amount of zeros

    #pragma omp parallel for schedule(guided)                           // Uses OpenMP to create multiple threads to run this loop in parallel
    for (int i = 1; i <= maxNumber; i++)                                // Loop from i = 1 to maxNumber (inclusive), increment by 1
    {
        if (findFactors(i, false) == true)                              // Is this number (i) prime?
        {
            primeList[i - 1] = i;                                       // Vectors start at 0 in C++
        }
    }

    for (int i = 0; i < maxNumber; i++)                                 // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
    {
        if (primeList[i] != 0)
        {
            primeList[numPrimes] = primeList[i];
            numPrimes++;                                                // Count up the number of primes we found
        }
    }
    return numPrimes;
}





// main is the default name for the starting point of a program in C++
//
int main(int argc, char *argv[])
{
    int maxNumber, numPrimes;                                           // local variables only visible to this function
    prime prime;                                                        // Creates a new instance of the prime class accessible to this function only
    maxNumber = atoi(argv[1]);                                          // atoi = Ascii TO Integer, argv[0] will be the name of the executable, the first argument is argv[1]
    numPrimes = prime.primeListTest(maxNumber);                         // Calculates all prime numbers up to maxNumber

    printf("Generated %d primes, Largest was: %d\n", numPrimes, prime.primeList[numPrimes - 1]);
}
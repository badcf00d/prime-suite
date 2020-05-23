#include <stdio.h>                                                      // Gives us printf 
#include <stdbool.h>                                                    // Gives us the bool type
#include <stdlib.h>                                                     // Gives us dynamic memory functions
#include <math.h>                                                       // Gives us math functions like sqrt
#include <sys/time.h>                                                   // Gives us gettimeofday
#include <time.h>                                                       // Gives us CPU clock functions

int* primeList;                                                         // Pointer variable accessible to anything in this file



// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
static bool findFactors(const int testNum, bool verbose)
{
    int const testLimit = (int) floor(sqrt((double) testNum));          // Local constant variable
    bool isPrime = true;

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) printf("Special case %d", testNum);                // %d means print an integer
    }
    else 
    {
        for (int i = 2; i <= 3; i++)                                    // Test for divisibility by 2 and 3
        {
            if ((testNum % i) == 0) 
            {
                isPrime = false;
                if (verbose) printf("divides by %d", i);
            }
        }
    }

    for (int divisor = 5; divisor <= testLimit; divisor += 6)           // Loop from divisor = 5 to testLimit (inclusive), increment by 6
    {      
        if ((testNum % divisor) == 0)                                   // Test if it divides by the divisor (i.e. 6k - 1)
        {                           
            if (verbose) printf("divides by %d", divisor); 
            isPrime = false;
        }

        if ((testNum % (divisor + 2)) == 0)                             // Test if it divides by the divisor + 2 (i.e. 6k + 1)
        {                       
            if (verbose) printf("divides by %d", divisor + 2);
            isPrime = false;
        }
    }

    return isPrime;
}



// Helper function for calculating all prime numbers up to maxNumber
//
static int primeListTest(const int maxNumber)
{
    int numPrimes = 0;

    primeList = calloc(maxNumber, sizeof(int));                         // Dynamic memory allocation & initialize to 0

    #pragma omp parallel for schedule(guided)                           // Uses OpenMP to create multiple threads to run this loop in parallel
    for (int i = 1; i <= maxNumber; i++)                                // Loop from i = 1 to maxNumber (inclusive), increment by 1 
    {                                                                   
        if (findFactors(i, false) == true)                              // Is this number (i) prime?
        {
            primeList[i - 1] = i;                                       // Arrays start at 0 in C
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




// main is the default name for the starting point of a program in C
//
int main() 
{
    int maxNumber, numPrimes;
    float apparentTime, cpuTime;
    struct timeval sysStart, sysFinish, sysTimeDiff;
    clock_t cpuStart, cpuFinish;

    printf("Generate all primes up to: ");
    scanf("%d", &maxNumber);                                            // Read from stdin as a number (%d)
    
    gettimeofday(&sysStart, NULL);                                      // Get the system time, this will be the apparent runtime
    cpuStart = clock();                                                 // Get the cpu time, this will be the cpu runtime
    numPrimes = primeListTest(maxNumber);                               // Calculates all prime numbers up to maxNumber
    cpuFinish = clock();                                                // Get finish cpu time
    gettimeofday(&sysFinish, NULL);                                     // Get the finishing system time

    timersub(&sysFinish, &sysStart, &sysTimeDiff);                      // Calculates the difference between sysStart and sysFinish
    apparentTime = sysTimeDiff.tv_sec + (sysTimeDiff.tv_usec * 1e-6);   // Add up the total time taken
    cpuTime = ((float) (cpuFinish - cpuStart)) / CLOCKS_PER_SEC;        // Convert the cpu ticks to seconds

    printf("Generated %d primes, Largest was: %d \n", numPrimes, primeList[numPrimes - 1]);
    printf("Apparent time = %7.3f seconds\n", apparentTime);
    printf("CPU time = %12.6f seconds\n", cpuTime);

    free(primeList);
}
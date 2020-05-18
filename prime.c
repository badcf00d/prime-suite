#include <stdio.h>                                                      // Gives us printf 
#include <stdbool.h>                                                    // Gives us the bool type
#include <stdlib.h>                                                     // Gives us dynamic memory functions
#include <math.h>                                                       // Gives us math functions like sqrt
#include <sys/time.h>                                                   // Gives us gettimeofday
#include <time.h>                                                       // Gives us CPU clock functions


int* primeList;                                                         // Pointer variable accessible to anything in this file



/* 
   Factor test by trial division using the 6k +- 1 optimisation, this
   means that factors of factors will not be displayed, i.e. if the test
   number is a factor of 2, it will not show 4, 6, 8 etc. 
*/
static bool findFactors(int testNum, bool verbose)
{
    int testLimit = (int) sqrt((double) testNum);                       // Local variable
    bool isPrime = true;

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) printf("Special case %d", testNum);                // %d means print an integer
    }
    else 
    {
        if ((testNum % 2) == 0) 
        {
            isPrime = false;
            if (verbose) printf("divides by 2");
        }
        if ((testNum % 3) == 0) 
        {
            isPrime = false;
            if (verbose) printf("divides by 3");
        }
    }

    #pragma omp parallel for                                            // Creates multiple threads, compile with -fopenmp
    for (int divisor = 5; divisor <= testLimit; divisor += 6)           // Loop from divisor = 6 to testLimit (inclusive), increment by 6
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


/* 
   Helper function for calculating all prime numbers up to maxNumber
*/
static int primeListTest(int maxNumber)
{
    int numPrimes = 0;
    bool isPrime;

    primeList = malloc(maxNumber * sizeof(int));                        // We won't actually need this much memory because not every number will be prime

    for (int i = 1; i <= maxNumber; i++)                                // Loop from i = 1 to maxNumber (inclusive), increment by 1 
    {                                                                   
        isPrime = findFactors(i, false);
        if (isPrime == true)
        {
            primeList[numPrimes] = i;                                   // Arrays start at 0 in C
            numPrimes++;
        }
    }

    return numPrimes;
}





int main() 
{
    int maxNumber, numPrimes;
    float apparentTime, cpuTime;
    struct timeval sysStart, sysFinish, sysTimeDiff;
    clock_t cpuStart, cpuFinish;

    printf("Generate all primes up to: ");
    scanf("%d", &maxNumber);
    
    gettimeofday(&sysStart, NULL);                                      // Get the system time, this will be the apparent runtime
    cpuStart = clock();                                                 // Get the cpu time, this will be the cpu runtime
    numPrimes = primeListTest(maxNumber);                               // Calculates all prime numbers up to maxNumber
    cpuFinish = clock();                                                // Get finish cpu time
    gettimeofday(&sysFinish, NULL);                                     // Get finish system time

    timersub(&sysFinish, &sysStart, &sysTimeDiff);
    apparentTime = sysTimeDiff.tv_sec + (sysTimeDiff.tv_usec * 1e-6);
    cpuTime = ((float) (cpuFinish - cpuStart)) / CLOCKS_PER_SEC;

    printf("\nGenerated %d primes, Largest was: %d \n", numPrimes, primeList[numPrimes - 1]);
    printf("Apparent time = %7.3f seconds\n", apparentTime);
    printf("CPU time = %12.6f seconds\n", cpuTime);

    free(primeList);
}
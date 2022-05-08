
#include "cuda_runtime.h"                                               // CUDA include files...
#include "device_launch_parameters.h"

#include <stdio.h>                                                      // Gives us printf
#include <stdbool.h>                                                    // Gives us the bool type
#include <stdlib.h>                                                     // Gives us dynamic memory functions
#include <math.h>                                                       // Gives us math functions like sqrt


static int* primeList;                                                  // Pointer variable accessible to anything in this file
#define checkCudaError(val) { cudaAssert((val), __FILE__, __LINE__); }  // Macro to provide more useful output on error
#define THREADS_PER_BLOCK 128                                           // Best threads per block from Nvidia Nsight

void cudaAssert(cudaError_t code, const char* file, int line)
{
    if (code != cudaSuccess)
    {
        fprintf(stderr, "CUDA error at %s:%d code=%d(%s)\n", file, line, code, cudaGetErrorString(code));
        exit(EXIT_FAILURE);
    }
}


// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
__global__ void findFactors(int* outputArray, bool verbose)
{
    int const testNum = threadIdx.x + (blockDim.x * blockIdx.x);        // Values set internally that tell us which block & thread this is
    int const testLimit = (int)floor(sqrt((double) testNum));           // Local constant variable
    int* const out = &outputArray[testNum];                             // Local constant pointer to a mutable integer
    bool isPrime = true;

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) printf("Special case %d\n", testNum);              // %d means print an integer
    }
    else
    {
        for (int i = 2; i <= 3; i++)                                    // Test for divisibility by 2 and 3
        {
            if ((testNum % i) == 0)
            {
                isPrime = false;
                if (verbose) printf("%d divides by %d\n", testNum, i);
            }
        }
    }

    if (isPrime)
    {
        for (int divisor = 5; divisor <= testLimit; divisor += 6)       // Loop from divisor = 5 to testLimit (inclusive), increment by 6
        {
            if ((testNum % divisor) == 0)                               // Test if it divides by the divisor (i.e. 6k - 1)
            {
                if (verbose) printf("%d divides by %d\n", testNum, divisor);
                isPrime = false;
            }

            if ((testNum % (divisor + 2)) == 0)                         // Test if it divides by the divisor + 2 (i.e. 6k + 1)
            {
                if (verbose) printf("%d divides by %d\n", testNum, divisor + 2);
                isPrime = false;
            }
        }
    }

    if (isPrime)
        *out = testNum;
}


// Helper function for calculating all prime numbers up to maxNumber
static int primeListTest(const int maxNumber)
{
    int const numBlocks = (maxNumber + (THREADS_PER_BLOCK - 1)) / THREADS_PER_BLOCK;            // Does a rounded-up division to work out how many blocks of threads we need for the requested number of primes
    int const allocSize = numBlocks * THREADS_PER_BLOCK * sizeof(int);                          // Total number of bytes of memory we need to allocate for the prime number buffers
    int* gpu_primeList;
    int numPrimes = 0;

    primeList = (int*)calloc(allocSize, 1);                                                     // Dynamic memory allocation on the host (i.e. in CPU RAM)

    checkCudaError(cudaMalloc((void**)&gpu_primeList, allocSize));                              // Dynamic memory allocation on the GPU
    checkCudaError(cudaMemcpy(gpu_primeList, primeList, allocSize, cudaMemcpyHostToDevice));    // Copy the contents of primeList (on the host/CPU) to gpu_primeList (on the GPU)

    // Tells the CUDA runtime to make numBlocks blocks each with THREADS_PER_BLOCK threads,
    // e.g if we requested 5 blocks each with 100 threads, the gpu would spawn 500 threads in total.
    // Each thread calls findFactors with the same paramaters. The CUDA runtime sets variables for each
    // thread that we can use to write to the correct memory location from each thread.
    findFactors<<<numBlocks, THREADS_PER_BLOCK>>>(gpu_primeList, false);

    checkCudaError(cudaMemcpy(primeList, gpu_primeList, allocSize, cudaMemcpyDeviceToHost));    // Copy the contents of gpu_primeList (on the GPU) back to primeList (on the host/CPU)
    checkCudaError(cudaFree(gpu_primeList));                                                    // Free the memory on the GPU

    for (int i = 0; i < maxNumber; i++)                                                         // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
    {
        if (primeList[i] != 0)
        {
            primeList[numPrimes] = primeList[i];
            numPrimes++;                                                                        // Count up the number of primes we found
        }
    }

    return numPrimes;
}




int main(int argc, char* argv[])
{
    int maxNumber, numPrimes;                                           // local variables only visible to this function
    maxNumber = atoi(argv[1]);                                          // atoi = Ascii TO Integer, argv[0] will be the name of the executable, the first argument is argv[1]
    numPrimes = primeListTest(maxNumber);                               // Calculates all prime numbers up to maxNumber

    printf("Generated %d primes, Largest was: %d \n", numPrimes, primeList[numPrimes - 1]);

    // cudaDeviceReset must be called before exiting in order for profiling and
    // tracing tools such as Nsight and Visual Profiler to show complete traces.
    checkCudaError(cudaDeviceReset());
    cudaFree(primeList);

    return 0;
}
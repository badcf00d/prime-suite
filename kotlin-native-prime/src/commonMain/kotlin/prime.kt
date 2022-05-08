import kotlinx.coroutines.*
import kotlin.math.*;                                                   // Gives us math functions like floor and sqrt

private lateinit var primeList : List<Int>;                             // An empty list that is visible to anything in this file, lateinit allows the value to be uninitialised


// A function signature for a map function that can run asyncronysly
// under a coroutuine. The input Iterable `A` is iterated over by function `f`
// with each input `it` asynchronously, while the awaitAll blocks the coroutine
// until completion.
suspend fun <A, B> Iterable<A>.parallelMap(f: suspend (A) -> B): List<B> = coroutineScope {
    map { async { f(it) } }.awaitAll()
}

// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
fun findFactors(testNum : Int, verbose : Boolean): Boolean
{
    val testLimit = (floor(sqrt(testNum.toDouble()))).toInt();          // Local constant
    var isPrime = true;                                                 // Local variable

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) println("Special case $testNum");                  // $ means print the value of the thing rather
    }
    else
    {
        for (i in 2..3)                                                 // Test for divisibility by 2 and 3
        {
            if ((testNum % i) == 0)
            {
                isPrime = false;
                if (verbose) println("divides by $i");
            }
        }
    }

    if (isPrime == true)
    {
        for (divisor in 5 until (testLimit + 1) step 6)                 // Loop from divisor = 5 to testLimit (inclusive), increment by 6
        {
            if ((testNum % divisor) == 0)                               // Test if it divides by the divisor (i.e. 6k - 1)
            {
                if (verbose) println("divides by $divisor");
                isPrime = false;
            }

            if ((testNum % (divisor + 2)) == 0)                         // Test if it divides by the divisor + 2 (i.e. 6k + 1)
            {
                if (verbose) println("divides by ${divisor + 2}");      // You can also use $ with {} to do some operations before printing
                isPrime = false;
            }
        }
    }
    return isPrime;
}


// Helper function for calculating all prime numbers up to maxNumber
//
fun primeListTest(maxNumber : Int) : Int
{
    primeList = runBlocking(Dispatchers.Default) {                      // Block while this section of code runs under a coroutine dispatcher that handles spawning threads
        (1..maxNumber).parallelMap {                                    // Creates a list from 1 to maxNumber (inclusive) and passes it to the function defined above that spawns a coroutine for each element
            if (findFactors(it, false) == true)
                it;                                                     // If prime, return the current value to primeList
            else
                0;                                                      // If not prime, return 0 to primeList
        }
    }

    primeList = primeList.filter { it != 0 };                           // Remove all of the zeros from the list
    return primeList.size;                                              // Return the number of primes in the list
}




// main is the default name for the starting point of a program in Java
//
fun main(args: Array<String>)
{
    var numPrimes : Int
    val maxNumber = args[0].toInt()                                     // Take the first argument and convert it to an integer

    numPrimes = primeListTest(maxNumber);

    println("Generated $numPrimes primes, Largest was: ${primeList[numPrimes - 1]}");
}

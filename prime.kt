import java.util.stream.IntStream;                                      // IntStream allows for easy parallel iteration
import kotlin.math.*;                                                   // Gives us math functions like floor and sqrt

var primeList : IntArray = intArrayOf(0);                               // An empty array that is only visible to anything in this file



// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
fun findFactors(testNum : Int, verbose : Boolean): Boolean
    {
        val testLimit = (floor(sqrt(testNum.toDouble()))).toInt();      // Local constant
        var isPrime = true;                                             // Local variable

        if (testNum <= 3)
        {
            isPrime = (testNum > 1);
            if (verbose) println("Special case $testNum");              // $ means print the value of the thing rather
        }
        else 
        {
            for (i in 2..3)                                             // Test for divisibility by 2 and 3
            {
                if ((testNum % i) == 0) 
                {
                    isPrime = false;
                    if (verbose) println("divides by $i");
                }
            }
        }

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

        return isPrime;
    }


// Helper function for calculating all prime numbers up to maxNumber
//
fun primeListTest(maxNumber : Int) : Int
    {
        var numPrimes = 0
        primeList = IntArray(maxNumber, {0})                            // Dynamic memory allocation, initialized to 0
        
        IntStream.range(1, (maxNumber + 1)).parallel().forEach() {      // Runs this section of code in parralel for each number in the IntStream range
            if (findFactors(it, false) == true)                         // 'it' in Kotlin is an implicit parameter for a Lambda functions like this 
            {
                primeList[it - 1] = it;                                 // Arrays start at 0 in Kotlin
            }
        }

        for (i in 0 .. (maxNumber - 1))                                 // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
        {
            if (primeList[i] != 0)
            {
                primeList[numPrimes] = primeList[i];
                numPrimes++;                                            // Count up the number of primes we found
            }
        }

        return numPrimes;
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
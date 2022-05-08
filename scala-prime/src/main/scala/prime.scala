import scala.math._;                                                    // Gives us math functions like floor and sqrt
import scala.collection.parallel.CollectionConverters._

class prime                                                             // Define a class for our prime number functions
{
    var primeList = Array.empty[Int];                                   // An empty array that is only visible to functions within this class


    // Factor test by trial division using the 6k +- 1 optimisation, this
    // means that factors of factors will not be displayed, i.e. if the test
    // number is a factor of 2, it will not show 4, 6, 8 etc.
    //
    def findFactors(testNum: Int, verbose: Boolean): Boolean = {
        val testLimit: Int = floor(sqrt(testNum)).toInt;                // Local constant variable
        var isPrime = true;

        if (testNum <= 3) {
            isPrime = (testNum > 1);
            if (verbose) println("Special case " + testNum);            // %d means print an integer
        }
        else {
            for (i <- 2 to 3)                                           // Test for divisibility by 2 and 3
            {
                if ((testNum % i) == 0) {
                    isPrime = false;
                    if (verbose) println("divides by " + i);
                }
            }
        }

        if (isPrime == true)
        {
            for (divisor <- 5 until (testLimit + 1) by 6)               // Loop from divisor = 5 to testLimit (inclusive), increment by 6
            {
                if ((testNum % divisor) == 0)                           // Test if it divides by the divisor (i.e. 6k - 1)
                    {
                        if (verbose) println("divides by " + divisor);
                        isPrime = false;
                    }

                if ((testNum % (divisor + 2)) == 0)                     // Test if it divides by the divisor + 2 (i.e. 6k + 1)
                    {
                        if (verbose) println("divides by " + (divisor + 2));
                        isPrime = false;
                    }
            }
        }
        return isPrime;
    }


    // Helper function for calculating all prime numbers up to maxNumber
    //
    def primeListTest(maxNumber: Int): Int = {
        var numPrimes = 0;
        var i = 0;
        primeList = new Array[Int](maxNumber);                          // Dynamic memory allocation, automatically initialized to 0

        (1 to maxNumber).toList.par.foreach { i =>
            if (findFactors(i, false) == true)                          // Is this number (i) prime?
            {
                primeList(i - 1) = i;                                   // Arrays start at 0 in Scala
            }
        }

        for (i <- 0 until maxNumber)                                    // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
        {
            if (primeList(i) != 0) {
                primeList(numPrimes) = primeList(i)
                numPrimes += 1;                                         // Count up the number of primes we found
            }
        }

        numPrimes;                                                      // Return numPrimes
    }
}


object scalaprime {
    def main(args: Array[String]): Unit = {                             // An object is an instance of a class
        val prime = new prime
        val maxNumber = Integer.parseInt(args(0))                       // Take the first command line argument and convert it to an integer
        val numPrimes = prime.primeListTest(maxNumber)

        println("Generated " + numPrimes + " primes, Largest was " + prime.primeList(numPrimes - 1))
    }
}
import java.util.Scanner;                                                   // Scanner is used to get user input from stdin
import java.util.stream.IntStream;                                          // IntStream allows for easy for-loop multithreading
import java.lang.Math;                                                      // Gives us math functions like floor and sqrt
import java.lang.management.ManagementFactory;                              // Used for cpu time measurements
import java.lang.management.ThreadMXBean;                                   // Used for cpu time measurements



public class prime                                                          // All code must be inside a class in Java     
{
    private int[] primeList;                                                // An empty array that is only visible to functions within this class


    // Factor test by trial division using the 6k +- 1 optimisation, this
    // means that factors of factors will not be displayed, i.e. if the test
    // number is a factor of 2, it will not show 4, 6, 8 etc.
    //
    public boolean findFactors(int testNum, boolean verbose)
    {
        final int testLimit = (int) Math.floor(Math.sqrt(testNum));         // Local constant variable
        boolean isPrime = true;

        if (testNum <= 3)
        {
            isPrime = (testNum > 1);
            if (verbose) System.out.printf("Special case %d", testNum);     // %d means print an integer
        }
        else 
        {
            for (int i = 2; i <= 3; i++)                                    // Test for divisibility by 2 and 3
            {
                if ((testNum % i) == 0) 
                {
                    isPrime = false;
                    if (verbose) System.out.printf("divides by %d", i);
                }
            }
        }

        for (int divisor = 5; divisor <= testLimit; divisor += 6)           // Loop from divisor = 5 to testLimit (inclusive), increment by 6
        {      
            if ((testNum % divisor) == 0)                                   // Test if it divides by the divisor (i.e. 6k - 1)
            {                           
                if (verbose) System.out.printf("divides by %d", divisor); 
                isPrime = false;
            }

            if ((testNum % (divisor + 2)) == 0)                             // Test if it divides by the divisor + 2 (i.e. 6k + 1)
            {                       
                if (verbose) System.out.printf("divides by %d", divisor + 2);
                isPrime = false;
            }
        }

        return isPrime;
    }
    


    // Helper function for calculating all prime numbers up to maxNumber
    //
    public int primeListTest(int maxNumber)
    {
        int numPrimes = 0;
        primeList = new int[maxNumber];                                     // Dynamic memory allocation, automatically initialized to 0

        IntStream.range(1, (maxNumber + 1)).parallel().forEach(i ->         // Loop from i = 1 to maxNumber (inclusive), increment by 1 
            {
                if (findFactors(i, false) == true)                          // Is this number (i) prime?
                {
                    primeList[i - 1] = i;                                   // Arrays start at 0 in Java
                }
            }
        );

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
    public static void main(String args[]) 
    { 
        // Using Scanner for Getting Input from User 
        Scanner stdin = new Scanner(System.in);
        prime prime = new prime();
        ThreadMXBean threadMXBean = ManagementFactory.getThreadMXBean();
        long sysStart, sysFinish;
        int numPrimes, maxNumber;
        double apparentTime, cpuTime = 0;

        System.out.print("Generate all primes up to: "); 
        maxNumber = stdin.nextInt(); 
        stdin.close();

        sysStart = System.nanoTime();
        numPrimes = prime.primeListTest(maxNumber);
        sysFinish = System.nanoTime();

        apparentTime = (sysFinish - sysStart) / 1e9;
        for (long id : threadMXBean.getAllThreadIds()) {
            cpuTime += threadMXBean.getThreadCpuTime(id);
        }
        cpuTime /= 1e9;

        System.out.printf("Apparent time = %7.3f seconds\n", apparentTime);
        System.out.printf("CPU time = %12.6f seconds\n", cpuTime);
        System.out.printf("Generated %d primes, Largest was: %d \n", numPrimes, prime.primeList[numPrimes - 1]);
    }    
}


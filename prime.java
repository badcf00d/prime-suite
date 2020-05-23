import java.util.Scanner;
import java.lang.Math;
import java.lang.management.ManagementFactory;
import java.lang.management.ThreadMXBean;

public class prime 
{
    private int[] primeList;

    public boolean findFactors(int testNum, boolean verbose)
    {
        final int testLimit = (int) Math.floor(Math.sqrt(testNum));          // Local constant variable
        boolean isPrime = true;

        if (testNum <= 3)
        {
            isPrime = (testNum > 1);
            if (verbose) System.out.printf("Special case %d", testNum);                // %d means print an integer
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

        primeList = new int[maxNumber];                         // Dynamic memory allocation & initialize to 0

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


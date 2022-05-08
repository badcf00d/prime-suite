
// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
function findFactors(testNum, verbose)
{
    const testLimit = Math.floor(Math.sqrt(testNum));                   // Local constant variable
    var isPrime = true;

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) console.log(`Special case ${testNum}`);            // ${} means print some variable, or the result of some expression
    }
    else
    {
        for (var i = 2; i <= 3; i++)                                    // Test for divisibility by 2 and 3
        {
            if ((testNum % i) == 0)
            {
                isPrime = false;
                if (verbose) console.log(`divides by ${i}`);
            }
        }
    }

    if (isPrime == true)
    {
        for (var divisor = 5; divisor <= testLimit; divisor += 6)       // Loop from divisor = 5 to testLimit (inclusive), increment by 6
        {
            if ((testNum % divisor) == 0)                               // Test if it divides by the divisor (i.e. 6k - 1)
            {
                if (verbose) console.log(`divides by ${divisor}`);
                isPrime = false;
            }

            if ((testNum % (divisor + 2)) == 0)                         // Test if it divides by the divisor + 2 (i.e. 6k + 1)
            {
                if (verbose) console.log(`divides by ${divisor + 2}`);
                isPrime = false;
            }
        }
    }
    return isPrime;
}



// Helper function for calculating all prime numbers up to maxNumber
//
function primeListTest(maxNumber)
{
    var numPrimes = 0;
    var primeList = [0];                                                // Global variable, array [] of numbers with just a single 0 in for now

    for (var i = 1; i <= maxNumber; i++)                                // Loop from i = 1 to maxNumber (inclusive), increment by 1
    {
        if (findFactors(i, false) == true)                              // Is this number (i) prime?
        {
            primeList[numPrimes] = i;                                       // Arrays start at 0 in JS
            numPrimes++;                                                // Count up the number of primes we found
        }
    }
    return [numPrimes, primeList];                                      // You can return arrays of objects in JS, which is handy
}




// This section of code will be the start because it's
// the first part that's not part of a definition for
// a function.
//
const maxNumber = parseInt(process.argv[2]);                            // argv[0] will be 'node', argv[1] will be the js file, the first argument is argv[2]
const [numPrimes, primeList] = primeListTest(maxNumber);                // Calculates all prime numbers up to maxNumber

console.log(`Generated ${numPrimes} primes, Largest was: ${primeList[numPrimes - 1]}`);

return process.exit(0);                                                 // node.js programs don't exit by themselves, need to manually exit (0 means no errors occured)

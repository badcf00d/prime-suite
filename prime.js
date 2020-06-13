var primeList = [0];                                                    // Global variable, array [] of numbers


function findFactors(testNum, verbose)
{
    const testLimit = Math.floor(Math.sqrt(testNum));                   // Local constant variable
    var isPrime = true;

    if (testNum <= 3)
    {
        isPrime = (testNum > 1);
        if (verbose) console.log(`Special case ${testNum}`);            // ${} means print an integer
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

    for (var divisor = 5; divisor <= testLimit; divisor += 6)           // Loop from divisor = 5 to testLimit (inclusive), increment by 6
    {      
        if ((testNum % divisor) == 0)                                   // Test if it divides by the divisor (i.e. 6k - 1)
        {                           
            if (verbose) console.log(`divides by ${divisor}`); 
            isPrime = false;
        }

        if ((testNum % (divisor + 2)) == 0)                             // Test if it divides by the divisor + 2 (i.e. 6k + 1)
        {                       
            if (verbose) console.log(`divides by ${divisor + 2}`);
            isPrime = false;
        }
    }
    return isPrime;
}




function primeListTest(maxNumber)
{
    var numPrimes = 0;

    for (var i = 1; i <= maxNumber; i++)
    {  
        primeList.push(0);                                              // A bit like dynamic memory allocation, initialize to 0
    }

    for (var i = 1; i <= maxNumber; i++)                                // Loop from i = 1 to maxNumber (inclusive), increment by 1 
    {                                                                   
        if (findFactors(i, false) == true)                              // Is this number (i) prime?
        {
            primeList[i - 1] = i;                                       // Arrays start at 0 in JS
        }
    }

    for (var i = 0; i < maxNumber; i++)                                 // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
    {
        if (primeList[i] != 0)
        {
            primeList[numPrimes] = primeList[i];
            numPrimes++;                                                // Count up the number of primes we found
        }
    }

    return numPrimes;
}


let maxNumber = parseInt(process.argv[2]);                          // argv[0] will be 'node', argv[1] will be the js file, the first argument is argv[2]
var numPrimes = primeListTest(maxNumber);                           // Calculates all prime numbers up to maxNumber

console.log(`Generated ${numPrimes} primes, Largest was: ${primeList[numPrimes - 1]}`);
return process.exit(0);                                             // node.js programs don't exit by themselves, need to manually exit

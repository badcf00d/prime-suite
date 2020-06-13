#![allow(non_snake_case)]                                               // Disables the warning about non snake case (e.g. hello_world) variables
use rayon::prelude::*;                                                  // Gives us the rayon multithreading functions (e.g. par_iter_mut)
use std::env;                                                           // Gives us command line argument functions


// Factor test by trial division using the 6k +- 1 optimisation, this
// means that factors of factors will not be displayed, i.e. if the test
// number is a factor of 2, it will not show 4, 6, 8 etc.
//
fn findFactors(testNum:i32, verbose:bool) -> bool
{
    let testLimit = (testNum as f64).sqrt().floor() as i32;             // Local constant
    let mut isPrime = true;                                             // Local variable

    if testNum <= 3
    {
        isPrime = testNum > 1;
        if verbose { println!("Special case {}", testNum); }            // {} means print an argument, a bit like % in C
    }
    else 
    {
        for i in 2..4                                                   // Test for divisibility by 2 and 3
        {
            if (testNum % i) == 0 
            {
                isPrime = false;
                if verbose { println!("divides by {}", i); }
            }
        }
    }

    for divisor in (5..(testLimit + 1)).step_by(6)                      // Loop from divisor = 5 to testLimit (inclusive), increment by 6
    {      
        if (testNum % divisor) == 0                                     // Test if it divides by the divisor (i.e. 6k - 1)
        {                           
            if verbose { println!("divides by {}", divisor); } 
            isPrime = false;
        }

        if (testNum % (divisor + 2)) == 0                               // Test if it divides by the divisor + 2 (i.e. 6k + 1)
        {                       
            if verbose { println!("divides by {}", divisor + 2); }
            isPrime = false;
        }
    }

    return isPrime;
}


// Helper function for calculating all prime numbers up to maxNumber
//
fn primeListTest(maxNumber:i32) -> (usize, Vec<usize>)
{
    let mut numPrimes:usize = 0;
    let mut primeList = vec![0; maxNumber as usize];                    // Dynamic memory allocation & initialize to 0

    primeList.par_iter_mut().enumerate().for_each(|(i, data)|           // Creates multiple threads that work on each element in primeList
        {
            if findFactors((i + 1) as i32, false) == true
            {
                *data = i + 1;
            }
        }
    );

    for i in 0..(maxNumber as usize)                                   // This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
    {
        if primeList[i] != 0
        {
            primeList[numPrimes] = primeList[i];
            numPrimes += 1;
        }
    }

    return (numPrimes, primeList);
}


// main is the default name for the starting point of a program in Rust
//
fn main() 
{
    let args: Vec<String> = env::args().collect();                      // Gets an array of strings containing all the command line arguments
    let maxNumber:i32 = args[1].parse().unwrap();                       // argv[0] will be the rs file, the first argument is argv[1], and convert to an integer
    let (numPrimes, primeList) = primeListTest(maxNumber);              // Calculates all prime numbers up to maxNumber

    println!("Generated {} primes, Largest was: {}", numPrimes, primeList[(numPrimes - 1)]);
}
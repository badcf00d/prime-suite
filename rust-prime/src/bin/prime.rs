#![allow(non_snake_case)]
use std::time::{Instant};
use cpu_time::ProcessTime;
use std::io::{stdin,stdout,Write};



fn findFactors(testNum:i32, verbose:bool) -> bool
{
    let testLimit = (testNum as f64).sqrt().floor() as i32;             // Local constant variable
    let mut isPrime = true;

    if testNum <= 3
    {
        isPrime = testNum > 1;
        if verbose { println!("Special case {}", testNum); }            // {} means print an argument
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



fn primeListTest(maxNumber:i32) -> (usize, Vec<usize>)
{
    let mut numPrimes:usize = 0;
    let mut isPrime:bool;
    let mut primeList = vec![0; maxNumber as usize];                    // Dynamic memory allocation & initialize to 0 - won't actually need this much memory because not every number will be prime

    for i in 1..((maxNumber + 1) as usize)                              // Loop from i = 1 to maxNumber (inclusive), increment by 1 
    {                                                                   
        isPrime = findFactors(i as i32, false);                         // Is this number (i) prime?
        if isPrime == true
        {
            primeList[numPrimes] = i;                                   // Arrays start at 0 in Rust
            numPrimes += 1;
        }
    }

    return (numPrimes, primeList);
}



fn main() 
{
    print!("Generate all primes up to: ");
    stdout().flush().ok().expect("Could not flush stdout");             // You must manually flush the buffer to stdout when using print!


    let mut buffer = String::new();                                     // This section of code reads the number from stdin 
    match stdin().read_line(&mut buffer) 
    {
        Ok(_n) => {}
        Err(error) => println!("error: {}", error),
    }
    let maxNumber:i32 = buffer.trim_end().parse().unwrap();


    let sysStart = Instant::now();                                      // Get the system time, this will be the apparent runtime
    let cpuStart = ProcessTime::now();                                  // Get the cpu time, this will be the cpu runtime
    let (numPrimes, primeList) = primeListTest(maxNumber);              // Calculates all prime numbers up to maxNumber
    let cpuTime = cpuStart.elapsed().as_secs_f64();                     // Get the cpu time since we started
    let apparentTime = sysStart.elapsed().as_secs_f64();                // Get the system time since we started

    println!("Generated {} primes, Largest was: {}", numPrimes, primeList[(numPrimes - 1)]);
    println!("Apparent time = {:.3} seconds", apparentTime);
    println!("CPU time = {:.6} seconds", cpuTime);
}
import Text.Printf                              -- Gives us printf
import System.Environment                       -- Gives us getArgs


-- Type declaration for the isPrime function, takes an Int, returns a Bool 
isPrime :: Int -> Bool                          
isPrime 0 = False                               -- Pattern matching to specify the output for specific values
isPrime 1 = False                               -- 1 is not prime
isPrime 2 = True                                -- 2 is prime
isPrime 3 = True                                -- 3 is prime
isPrime x = ((x `mod` 2) /= 0) &&               -- For any other number (x) 
            ((x `mod` 3) /= 0) &&
            ([factorList | factorList <- [5 .. (floor.sqrt.fromIntegral) x], x `mod` factorList == 0] == []) -- This big one-liner
                                                -- is a list comprehension that says make a list of numbers called factorList that
                                                -- has all the numbers from 5 up to floor(sqrt(x)) where x modulo that number is 
                                                -- equal to 0. If that list is empty i.e. [], then the number x is not 
                                                -- divisible by any of those numbers 5 up to floor(sqrt(x))


-- Says that primeListTest takes a single Int, returns an array of Ints
primeListTest :: Int -> [Int]                   
primeListTest maxNumber = [primeList | primeList <- [1..maxNumber], isPrime primeList] -- Another list comprehension 
                                                -- for making a list of numbers from 1 to maxNumber where isPrime 
                                                -- returns True for that number.


-- Says that main is an IO funciton, in this case takes some stdin arguments, and prints some results to stdout
main :: IO ()
main = do
    args <- getArgs                             -- The <- operator gives us the IO output of a function (getArgs here)
    let maxNumber = (read (head args)) :: Int   -- We take the head (first element) of args, and read it as an Int
    let primeList = primeListTest maxNumber     -- Get the primeList from the primeListTest function

    printf "Generated %d primes, Largest was: %d \n" (length primeList) (last primeList)

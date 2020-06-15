import Text.Printf                                                      -- Gives us printf
import System.Environment                                               -- Gives us getArgs
import Control.Parallel.Strategies                                      -- Gives us multi-threading capabilities



-- The big one-liner in this next function with the pipe | symbols is a list
-- comprehension that says make a list of numbers called factorList that has 
-- all the numbers from 5 up to floor(sqrt(x)) where x modulo that number is 
-- equal to 0. If that list is empty i.e. [], then the number x is not 
-- divisible by any of those numbers 5 up to floor(sqrt(x)).
--
-- Type declaration for the isPrime function, takes an Int, returns a Int 
isPrime :: Int -> Int                          
isPrime 0 = 0                                                           -- Pattern matching to specify the output for special case values
isPrime 1 = 0                                                           -- 1 is not prime
isPrime 2 = 2                                                           -- 2 is prime
isPrime 3 = 3                                                           -- 3 is prime
isPrime x = if ((x `mod` 2) /= 0) &&                                    -- For any other number (x) 
               ((x `mod` 3) /= 0) &&
               ([factorList | factorList <- [5 .. (floor.sqrt.fromIntegral) x], x `mod` factorList == 0] == [])
            then x                                                      -- Return the original number
            else 0                                                      -- Return 0, so we can do a list comprehension later to ignore this number
                                                



-- The type enclosed in brackets says this function takes another function as an input,
-- that function takes a single Int, and returns another Int. Then moving past the brackets
-- we say this parallelList function takes in an list of Ints, and returns another list of Ints.
parallelList :: (Int -> Int) -> [Int] -> [Int]
parallelList func list = map func list `using` parListChunk 1000 rseq   -- The map function takes a function and applies it to each element of a list,
                                                                        -- then the `using` statement says we want to run that map function with a parallel 
                                                                        -- strategy which is parListChunk 1000 (read as parallel list in chunks of 1000), rseq
                                                                        -- means run sequentially, i.e. wait until each call to func returns before calling again.




-- Takes a single Int, returns an list of Ints
primeListTest :: Int -> [Int]                   
primeListTest maxNumber = [primeList | primeList <- parallelList isPrime [1..maxNumber], primeList /= 0]
                                                                        -- List comprehension to make a list of numbers from 1 to maxNumber for which isPrime 
                                                                        -- returns True, also making use of our parallelList function to compute primes in parallel.




-- The main IO funciton, this is the only type main can be
main :: IO ()
main = do                                                               -- The do operator allows us to declare a section of code to run line-by-line
    args <- getArgs                                                     -- The <- operator gives us the IO output of a function (getArgs here)
    let maxNumber = read(head(args)) :: Int                             -- We take the head (first element) of args, and read it as an Int
    let primeList = primeListTest maxNumber                             -- Get the primeList from the primeListTest function

    printf "Generated %d primes, Largest was: %d \n" (length primeList) (last primeList)

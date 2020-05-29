with Ada.Numerics.Elementary_Functions;                                         -- Gives us math functions like sqrt and floor
with Ada.Text_IO;                                                               -- Gives us Put and Get for doing terminal interaction
with Ada.Calendar;                                                              -- Gives us system timing functionality
with Ada.Real_Time;                                                             -- Gives us CPU timing functions
with Ada.Execution_Time;                                                        -- Gives us CPU timing functions

use Ada.Numerics.Elementary_Functions;                                          -- Use treates the library as if it's local so you just say func() rather than library.func()
use Ada.Text_IO;



procedure Prime is
    maxNumber : Integer;                                                        -- Variables just visible to this procedure
    numPrimes : Integer;
    sysStart : Ada.Calendar.Time;                                               -- Using types declared in external libraries
    sysFinish : Ada.Calendar.Time;
    cpuStart : Ada.Execution_Time.CPU_Time;
    cpuFinish : Ada.Execution_Time.CPU_Time;
    apparentTime : Duration;
    cpuTime : Duration;
    type primeListType is array(Integer range <>) of Integer;                   -- Declare a new integer array data type that can be indexed by integers
    


    -- Factor test by trial division using the 6k +- 1 optimisation, this
    -- means that factors of factors will not be displayed, i.e. if the test
    -- number is a factor of 2, it will not show 4, 6, 8 etc.
    --
    function findFactors(testNum : Integer; verbose : Boolean) return Boolean is 
        testLimit : Integer;                                                    -- Local integer variable
        divisor   : Integer := 5;                                               -- := is the assignment operator, = is for logical comparison
        isPrime   : Boolean := True;                                              
    begin
        testLimit := Integer(Float'Floor(Sqrt(Float(testNum))));                -- Cast testNum to float, sqrt it, floor it, then cast back to integer

        if testNum <= 3 then
            isPrime := (testNum > 1);
            if (verbose) then Put_Line("Special case" & Integer'Image(testNum)); end if; -- & is the string contatenator, Integer'Image converts an integer to a string
        else 
            for i in 2 .. 3 loop                                                -- Test for divisibility by 2 and 3
                if ((testNum rem i) = 0) then                                   -- rem is equivalent to the modulo operator % in other languages
                    isPrime := False;
                    if (verbose) then Put_Line("divides by" & Integer'Image(i)); end if;
                end if;
            end loop;
        end if;
            
        while divisor <= testLimit loop                                         -- Loop from divisor = 5 to testLimit (inclusive)
            if ((testNum rem divisor) = 0) then                                 -- Test if it divides by the divisor (i.e. 6k - 1)
                if (verbose) then Put_Line("divides by" & Integer'Image(divisor)); end if; 
                isPrime := False;
            end if;

            if ((testNum rem (divisor + 2)) = 0) then                           -- Test if it divides by the divisor + 2 (i.e. 6k + 1)
                if (verbose) then Put_Line("divides by" & Integer'Image((divisor + 2))); end if;
                isPrime := False;
            end if;

            divisor := divisor + 6;                                             -- Ada only allows steps of 1 in for loops, so incrementing here with a while loop instead
        end loop;

        return isPrime;
    end findFactors;



    -- Helper function for calculating all prime numbers up to maxNumber
    --
    function primeListTest(maxNumber : Integer; primeList : in out primeListType) return Integer is
        numPrimes : Integer := 0;
    begin

        for i in 1 .. maxNumber loop                                            -- Loop from i = 1 to maxNumber (inclusive), increment by 1 
            if findFactors(i, False) = True then                                -- Is this number (i) prime?
                primeList(i - 1) := i;                                          -- Arrays start at 0 in Ada
            end if;
        end loop;

        for i in 0 .. (maxNumber - 1) loop                                      -- This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
            if primeList(i) /= 0 then
                primeList(numPrimes) := primeList(i);
                numPrimes := numPrimes + 1;                                     -- Count up the number of primes we found
            end if;
        end loop;

        return numPrimes;
    end primeListTest;



-- A naked begin is the equivalent of main() in other languages
--
begin
    Put("Generate all primes up to: ");
    maxNumber := Integer'Value(Get_Line);

    declare                                                                     -- Ada does not allow declaring variables in the body of a funciton, unless you do this
        primeList : primeListType(0..maxNumber) := (others => 0);               -- Dynamic memory allocation & initialize to 0
    begin
        sysStart := Ada.Calendar.Clock;
        cpuStart := Ada.Execution_Time.Clock;
        numPrimes := primeListTest(maxNumber, primeList);
        cpuFinish := Ada.Execution_Time.Clock;
        sysFinish := Ada.Calendar.Clock;

        apparentTime := Ada.Calendar."-" (sysFinish, sysStart);                -- An example of using an operator declared in another library
        cpuTime := Ada.Real_Time.To_Duration((Ada.Execution_Time."-" (cpuFinish, cpuStart)));

        Put_Line("Generated" & Integer'Image(numPrimes) & " primes, Largest was:" & Integer'Image(primeList(numPrimes - 1)));
        Put_Line("Apparent Time =" & Duration'Image(apparentTime) & " seconds");
        Put_Line("CPU Time =" & Duration'Image(cpuTime) & " seconds");
    end;
end Prime;
module primeMod                                                         ! Essentially like a class
    use omp_lib
    implicit none                                                       ! Don't allow implicit data types
    integer, dimension(:), allocatable  :: primeList
    public                              :: primeList                    ! Allows access to anything that uses primeMod

    contains                                                            ! Separates module's data area from the module's code area

    ! Factor test by trial division using the 6k +- 1 optimisation, this
    ! means that factors of factors will not be displayed, i.e. if the test
    ! number is a factor of 2, it will not show 4, 6, 8 etc.
    !
    function findFactors(testNum, verbose) result(isPrime)
        integer, intent(in) :: testNum                                  ! (in)put variable
        integer             :: divisor, testLimit                       ! Local variable
        logical, intent(in) :: verbose
        logical             :: isPrime

        testLimit = int(floor(dsqrt(dble(testNum))))                    ! Explicitly casting to avoid warnings
        isPrime = .true.                                                ! .xxx. is a logical operator

        if (testNum <= 3) then
            isPrime = (testNum > 1)
            if (verbose) write(*,*) 'Special case', testNum             ! The first * means write to stdout, the next * means auto-format
        else
            do divisor = 2, 3                                           ! Test for divisibility by 2 and 3
                if (mod(testNum, divisor) == 0) then
                    isPrime = .false.
                    if (verbose) write(*,*) 'divides by ', divisor
                end if
            end do
        end if

        if (isPrime .eqv. .true.) then
            do divisor = 5, testLimit, 6                                ! Loop from divisor = 5 to testLimit (inclusive), increment by 6
                if (mod(testNum, divisor) == 0) then                    ! Test if it divides by the divisor (i.e 6k - 1)
                    if (verbose) write(*,*) 'divides by', divisor
                    isPrime = .false.
                end if

                if (mod(testNum, divisor + 2) == 0) then                ! Test if it divides by the divisor + 2 (i.e 6k + 1)
                    if (verbose) write(*,*) 'divides by', divisor + 2
                    isPrime = .false.
                end if
            end do
        end if
    end function findFactors



    ! Helper function for calculating all prime numbers up to maxNumber
    !
    function primeListTest(maxNumber) result(numPrimes)
        integer, intent(in)         :: maxNumber
        integer                     :: numPrimes, i

        allocate(primeList(maxNumber))                                  ! Dynamic memory allocation

        !$omp parallel do schedule(guided)                              ! Creates multiple threads, compile with -fopenmp
        do i = 1, maxNumber                                             ! Loop from i = 1 to i = maxNumber (inclusive), increment i by 1 (default)
            if (findFactors(i, .false.) .eqv. .true.) then              ! Is this number prime?
                primeList(i) = i                                        ! Arrays start at 1 in fortran
            else
                primeList(i) = 0                                        ! Otherwise set it to 0, this helps us in the loop below
            end if
        end do
        !$omp end parallel do

        numPrimes = 0                                                   ! This loop essentially removes the blanks and bunches all the primes up next to eachother in primeList
        do i = 1, maxNumber
            if (primeList(i) /= 0) then
                numPrimes = numPrimes + 1                               ! Count up the number of primes we found
                primeList(numPrimes) = primeList(i)
            end if
        end do

    end function primeListTest
end module primeMod





program prime
    use primeMod                                                        ! Includes the functions and data specified in the primeMod module above
    implicit none
    integer             :: maxNumber, numPrimes
    character(len=32)   :: argBuffer

    call get_command_argument(1, argBuffer)                             ! Gets the first command line argument, stores it as a string in argBuffer
    read(argBuffer, '(I32)') maxNumber                                  ! Reads a 32 character integer, the number may be shorter, but it will be cut off if longer

    numPrimes = primeListTest(maxNumber)                                ! Calculates all prime numbers up to maxNumber

    write(*,*) 'Generated ', numPrimes, ' primes, Largest was: ', primeList(numPrimes)
    deallocate(primeList)
end program prime
module primeMod                                                         ! Essentially like a class
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

        testLimit = int(dsqrt(dble(testNum)))                           ! Explicitly casting to avoid warnings
        isPrime = .true.                                                ! .xxx. is a logical operator

        if (testNum <= 3) then
            isPrime = (testNum > 1)
            if (verbose) write(*,*) 'Special case', testNum             ! The first * means write to stdout, the next * means auto-format
        else 
            if (mod(testNum, 2) == 0) then
                isPrime = .false.
                if (verbose) write(*,*) 'divides by 2'                      
            end if
            if (mod(testNum, 3) == 0) then
                isPrime = .false.
                if (verbose) write(*,*) 'divides by 3'
            end if
        end if

        !$OMP PARALLEL DO                                               ! Creates multiple threads, compile with -fopenmp
        do divisor = 5, testLimit, 6                                    ! Equivalent to: for (i = 5; i < j; j += 6)
            if (mod(testNum, divisor) == 0) then                        ! Test if it divides by the divisor (i.e 6k - 1)
                if (verbose) write(*,*) 'divides by', divisor
                isPrime = .false.
            end if

            if (mod(testNum, divisor + 2) == 0) then                    ! Test if it divides by the divisor + 2 (i.e 6k + 1)
                if (verbose) write(*,*) 'divides by', divisor + 2
                isPrime = .false.
            end if
        end do
        !$OMP END PARALLEL DO
    end function findFactors



    ! Helper function for calculating all prime numbers up to maxNumber
    !
    function primeListTest(maxNumber) result(numPrimes)
        integer, intent(in) :: maxNumber
        integer             :: i, numPrimes
        logical             :: isPrime

        allocate(primeList(maxNumber))                                  ! We won't actually need this much memory because not every number will be prime
        numPrimes = 0

        do i = 1, maxNumber                                             ! Loop from i = 1 to i = maxNumber, increment i by 1 (default)
            isPrime = findFactors(i, .false.)                           ! Is this number prime?

            if (isPrime .eqv. .true.) then
                primeList(numPrimes + 1) = i                            ! Arrays start at 1 in fortran
                numPrimes = numPrimes + 1
            end if
        end do
    end function primeListTest  
end module primeMod





program prime
    use primeMod                                                        ! Works a bit like #include
    implicit none
    integer :: maxNumber, numPrimes, sysStart, sysFinish, sysClkRate
    real    :: cpuStart, cpuFinish, apparentTime, cpuTime

    write(*,'(a)', advance="no") ' Generate all primes up to: '         ! '(a)' means string format, no advance means no newline at the end
    read(*,*) maxNumber                                                 ! The first * means read from stdin, the next * means auto-format

    call system_clock(sysStart, sysClkRate)                             ! Get the system time, this will be the apparent runtime
    call cpu_time(cpuStart)                                             ! Get the cpu time, this will be the cpu runtime
    numPrimes = primeListTest(maxNumber)                                ! Calculates all prime numbers up to maxNumber
    call cpu_time(cpuFinish)                                            ! Get finish cpu time
    call system_clock(sysFinish, sysClkRate)                            ! Get finish system time

    apparentTime = ((sysFinish - sysStart) / real(sysClkRate))
    cpuTime = (cpuFinish - cpuStart)

    write(*,*) 'Generated ', numPrimes, ' primes, Largest was: ', primeList(numPrimes)
    write(*,'(a f7.3 a)') ' Apparent time = ', apparentTime, ' seconds'
    write(*,'(a f12.6 a)') ' CPU time = ', cpuTime, ' seconds'

    deallocate(primeList)
end program prime
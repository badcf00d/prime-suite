module primeMod                                                 ! Essentially like a class
    implicit none                                               ! Don't allow implicit data types

    integer, parameter  :: bigKind = selected_int_kind(20)      ! Constant specifying a data kind that can hold 20 decimal digits
    integer             :: sysStart, sysFinish, sysClkRate      ! Variables for timing the apparent runtime
    real                :: cpuStart, cpuFinish                  ! Variables for timing the cpu runtime
    real                :: apparentTime, cpuTime                ! More timing variables
    public              :: bigKind                              ! Allows access to anything that uses primeMod
    private             :: sysStart, sysFinish, sysClkRate      ! Only seen by code within this module
    private             :: cpuStart, cpuFinish
    private             :: apparentTime, cpuTime 

    contains                                                    ! Separates module's data area from the module's code area

    ! Factor test by trial division using the 6k +- 1 optimisation, this
    ! means that factors of factors will not be displayed, i.e. if the test
    ! number is a factor of 2, it will not show 4, 6, 8 etc.
    ! 
    function findFactors(testNum, verbose) result(isPrime)
        integer(kind=bigKind), intent(in)   :: testNum          ! (in)put variable
        integer(kind=bigKind)               :: divisor          ! Local variable
        integer(kind=bigKind)               :: testLimit        ! Local variable
        logical, intent(in)                 :: verbose          ! Print out the successful divisor
        logical                             :: isPrime          ! Result value is automatically intent(out) ?

        testLimit = int(dsqrt(dble(testNum)), kind=bigKind)     ! Explicitly casting to avoid warnings
        isPrime = .true.                                        ! .xxx. is a logical operator

        if (mod(testNum, 2) == 0) then
            isPrime = .false.
            if (verbose) write(*,*) 'divides by 2'              ! The first * means write to stdout, the next * means auto-format
        end if
        if (mod(testNum, 3) == 0) then
            isPrime = .false.
            if (verbose) write(*,*) 'divides by 3'
        end if

        !$OMP PARALLEL DO                                       ! Creates multiple threads, compile with -fopenmp
        do divisor = 5, testLimit, 6                            ! Equivalent to: for (i = 5; i < j; j += 6)
            if (mod(testNum, divisor) == 0) then                ! Test if it divides by the divisor (i.e 6k - 1)
                if (verbose) write(*,*) 'divides by', divisor
                isPrime = .false.
            end if

            if (mod(testNum, divisor + 2) == 0) then            ! Test if it divides by the divisor + 2 (i.e 6k + 1)
                if (verbose) write(*,*) 'divides by', divisor + 2
                isPrime = .false.
            end if
        end do
        !$OMP END PARALLEL DO
    end function findFactors



    ! Helper function to benchmark the factorisation of testNum
    !
    subroutine primalityTest(testNum)
        integer(kind=bigKind), intent(in)   :: testNum
        logical                             :: isPrime

        call system_clock(sysStart, sysClkRate)                 ! Get the system time, this will be the apparent runtime
        call cpu_time(cpuStart)                                 ! Get the cpu time, this will be the cpu runtime
        isPrime = findFactors(testNum, .true.)                  ! Test our number
        call cpu_time(cpuFinish)
        call system_clock(sysFinish, sysClkRate)
    
        if (isPrime .eqv. .true.) then                          ! Can't use == for boolean comparison, .eqv. means equivalent to
            write(*,*) 'prime'
        else
            write(*,*) 'not prime'
        end if

        apparentTime = ((sysFinish - sysStart) / real(sysClkRate))
        cpuTime = (cpuFinish - cpuStart)

        write(*,'(/, a f7.3 a a f12.6 a)') ' Primality test - ', apparentTime, ' seconds,', &
                                           ' CPU time = ', cpuTime, ' seconds'
    end subroutine primalityTest



    ! Helper function to benchmark calculating all prime numbers up to 1000000
    !
    subroutine primeListTest()
        integer(kind=bigKind)   :: i
        logical                 :: isPrime

        call system_clock(sysStart, sysClkRate)
        call cpu_time(cpuStart)
        do i = 1, 1000000
            isPrime = findFactors(i, .false.)
        end do
        call cpu_time(cpuFinish)
        call system_clock(sysFinish, sysClkRate)
    
        apparentTime = ((sysFinish - sysStart) / real(sysClkRate))
        cpuTime = (cpuFinish - cpuStart)
        
        write(*,'(a f7.3 a a f12.6 a)') ' Prime list test - ', apparentTime, ' seconds,', &
                                        ' CPU time = ', cpuTime, ' seconds'
    end subroutine primeListTest  
end module primeMod





program prime
    use primeMod                                                ! Works a bit like #include
    implicit none                                               ! Don't allow implicit data types

    integer(kind=bigKind) :: i                                  ! Use our bigKind type specified in primeMod

    write(*,'(a)', advance="no") ' Enter a test number: '       ! No advance means no newline at the end
    read(*,*) i                                                 ! The first * means read from stdin, the next * means auto-format

    call primalityTest(i)                                       ! Calculates all the base factors of i
    call primeListTest()                                        ! Calculates all prime numbers up to 1000000
end program prime
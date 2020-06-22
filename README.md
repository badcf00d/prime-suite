# prime-suite
This shows an implementation of a prime number calculator written in many different languages to demonstrate how the same program compares when written different languages, as well as showing roughly how performant each language can be.

#### How to use
 - Install all of the prerequisites: `gfortran gcc g++ default-jdk go gnat haskell-platform nodejs python3`, [kotlin](https://kotlinlang.org/docs/tutorials/command-line.html), [gradle](https://gradle.org/install/) and [rustup](https://rustup.rs/)
   - You could use the commands from [actions script](https://github.com/badcf00d/prime-suite/blob/master/.github/workflows/test_build.yml) to install these.
 - `make` runs the default `all` recipe which compiles all of the source files.
   - If you want to just make one of the languages do `make` and then the language e.g. `make fortran`
 - The programs take a numerical argument e.g. `c-prime 100` or `python3 prime.py 100` which will produce all the primes up to 100 (inclusive). 
   - The only slight exception is Haskell where you need some additional arguments to enable multithreading e.g. `haskell-prime 100 +RTS -N<number of threads>`
 - `make clean` deletes all of the files created by the build process.
 
#### Source Contents
```
├── Makefile                            # Makefile for GNU Make
├── prime.adb                           # Ada source file
├── prime.c                             # C source file
├── prime.cpp                           # C++ source file
├── prime.f90                           # Fortran source file
├── prime.go                            # Go source file
├── prime.hs                            # Haskell source file
├── prime.java                          # Java source file
├── prime.js                            # JavaScript source file
├── prime.py                            # Python 3 source file
├── kotlin-native-prime
│   └── src
│       └── commonMain
│           └── kotlin
│               └── prime.kt            # Kotlin source file
└── rust-prime
    └── src
        └── bin
            └── prime.rs                # Rust source file
```
---

#### Multi-threading

 🗙 **Ada** - Does support creating task functions that may be run as a thread, but does not have support for doing highly parallel iteration in a concise way.

 🗙 **JavaScript** - Can spawn child processes through the `worker_threads` API, but does not have any sort of multi-threading support within a program.
 
 🗙 **Kotlin Native** - The kotlinx-coroutines-core-native library does not support multi-threading so for the moment this version is broken until support is added, see issue https://github.com/Kotlin/kotlinx.coroutines/issues/462.

 ✓ **C** - Supports OpenMP through `#pragma omp`.
 
 ✓ **C++** - Supports OpenMP through `#pragma omp`.
 
 ✓ **Fortran** - Supports OpenMP through `!$omp`.
 
 ✓ **Go** - Goroutines combined with WaitGroups are a reasonably consise way of making a parallel section of code.
 
 ✓ **Java** - The IntStream class provides the `parallel().forEach()` method which is a multi-threaded iterator.
 
 ✓ **Haskell** - The `parallel` package provides multi-threaded list strategies.
 
 ✓ **Python** - Supports multi-threading with `ThreadPoolExecutor` from concurrent.futures, and multi-processing from `multiprocessing`. The multi-processing approach was significantly faster in this example so that is what's used here.
 
 ✓ **Rust** - The Rayon library adds supports for the `par_iter_mut().enumerate().for_each()` method which provides a multi-threaded iterator.
 

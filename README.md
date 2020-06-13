# prime-suite
This shows an implementation of a prime number calculator written in many different languages to demonstrate how the same program compares when written different languages, as well as showing roughly how performant each language can be.

#### How to use
 - `make` runs the default `all` recipe which compiles all of the source files, you'll also need `gfortran`, `gcc`, `javac`, `go`, `gnat` `haskell-platform` and `rustup` installed.
 - `make clean` deletes all of the files created by the build process.
 - The programs take a numerical argument e.g. `c-prime 100` or `python prime.py 100` which will produce all the primes up to 100 (inclusive).
 
#### Contents
```
├── LICENSE                       # BSC 2-Clause license
├── Makefile                      # Makefile for GNU Make
├── prime.adb                     # Ada source file
├── prime.c                       # C source file
├── prime.f90                     # Fortran source file
├── prime.go                      # Go source file
├── prime.hs                      # Haskell source file
├── prime.java                    # Java source file
├── prime.js                      # JavaScript source file
├── prime.py                      # Python 3 source file
├── README.md                     # Readme Markdown file
└── rust-prime
    ├── Cargo.toml                # Rust cargo manifest file
    └── src
        └── bin
            └── prime.rs          # Rust source file
```
---

#### Multi-threading

 🗙 **Ada** - Does support creating task functions that may be run as a thread, but does not have support for doing highly parallel iteration in a concise way.

 🗙 **JavaScript** - Can spawn child processes through the `worker_threads` API, but does not have any sort of multi-threading support within a program.

 ✓ **C** - Supports OpenMP through `#pragma omp`.
 
 ✓ **Fortran** - Supports OpenMP through `!$omp`.
 
 ✓ **Go** - Goroutines combined with WaitGroups are a reasonably consise way of making a parallel section of code.
 
 ✓ **Java** - The IntStream class provides the `parallel().forEach()` method which is a multi-threaded iterator.
 
 ✓ **Python** - Supports multi-threading with `ThreadPoolExecutor` from concurrent.futures, and multi-processing from `multiprocessing`. The multi-processing approach was significantly faster in this example so that is what's used here.
 
 ✓ **Rust** - The Rayon library adds supports for the `par_iter_mut().enumerate().for_each()` method which provides a multi-threaded iterator.

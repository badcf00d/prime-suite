# prime-suite
This shows an implementation of a multi-threaded prime number calculator written in many different languages to demonstrate how the same program compares when written different languages, as well as showing roughly how performant each language can be.

#### How to use
 - `make` runs the default `all` recipe which compiles all of the source files, you'll also need `gfortran`, `gcc`, and `rustup` installed.
 - `make clean` deletes all of the files created by the build process.
 
#### Contents
```
├── LICENSE                       # BSC 2-Clause license
├── Makefile                      # Makefile for GNU Make
├── prime.c                       # C source file
├── prime.f90                     # Fortran source file
├── prime.java                    # Java source file
├── prime.js                      # JavaScript (single-threaded) source file
├── prime.py                      # Python 3 source file
├── README.md                     # Readme Markdown file
└── rust-prime
    ├── Cargo.toml                # Rust cargo manifest file
    └── src
        └── bin
            └── prime.rs          # Rust source file
```

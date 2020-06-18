
#
# Compilers
#
FC := gfortran
CC := gcc
JC := javac
GC := go
AC := gnatmake
HC := ghc
CPPC := g++

#
# Flags
#
CFLAGS := -Wall -O2 -fopenmp -march=native -fverbose-asm
LDFLAGS := -fopenmp -lm
ADAFLAGS := -Wall -O2 -march=native
HSKFLAGS := -Wall -O2 -dynamic -threaded -package parallel
GEN_PROFILE_CFLAGS = -fprofile-generate -fprofile-update=single -pg
USE_PROFILE_CFLAGS = -fprofile-use -Wno-error=coverage-mismatch


#
# Setting directories
#
SRC_DIR := .
OBJ_DIR := .
RUST_DIR := ./rust-prime
RUST_SRC_DIR := $(RUST_DIR)/src/bin
RUST_OUT_DIR := $(RUST_DIR)/target/release


#
# Locating source files
#
F90SRC := $(wildcard $(SRC_DIR)/*.f90)
F90OBJ := $(F90SRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.fortran.o)
F90ASM := $(F90SRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.s)
F90MOD := $(wildcard $(SRC_DIR)/*.mod)

CSRC := $(wildcard $(SRC_DIR)/*.c)
COBJ := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.c.o)
CASM := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.s)
CPRE := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.i)
CCBC := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.bc)

RUSTSRC := $(wildcard $(RUST_DIR)/*.rs)

JAVSRC := $(wildcard $(SRC_DIR)/*.java)
JAVOUT := $(JAVSRC:$(SRC_DIR)/%.java=$(OBJ_DIR)/%.class)

GOSRC := $(wildcard $(SRC_DIR)/*.go)

ADASRC := $(wildcard $(SRC_DIR)/*.adb)
ADAOBJ := $(ADASRC:$(SRC_DIR)/%.adb=$(SRC_DIR)/%.o)
ADAALI := $(ADASRC:$(SRC_DIR)/%.adb=$(SRC_DIR)/%.ali)

HSKSRC := $(wildcard $(SRC_DIR)/*.hs)
HSKOBJ := $(HSKSRC:$(SRC_DIR)/%.hs=$(SRC_DIR)/%.haskell.o)
HSKINT := $(HSKSRC:$(SRC_DIR)/%.hs=$(SRC_DIR)/%.hi)

CPPSRC := $(wildcard $(SRC_DIR)/*.cpp)
CPPOBJ := $(CPPSRC:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.cpp.o)
CPPASM := $(CPPSRC:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.s)
CPPPRE := $(CPPSRC:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.i)
CPPCBC := $(CPPSRC:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.bc)


#
# Deciding what the executables will be called
#
ifeq ($(OS),Windows_NT)
	F90OUT := fortran-prime.exe
	COUT := c-prime.exe
	RUSTOUT := $(RUST_OUT_DIR)/rust-prime.exe
	GOOUT := go-prime.exe
	ADAOUT := ada-prime.exe
	HSKOUT := haskell-prime.exe
	CPPOUT := cpp-prime.exe
else
	F90OUT := fortran-prime
	COUT := c-prime
	RUSTOUT := $(RUST_OUT_DIR)/rust-prime
	GOOUT := go-prime
	ADAOUT := ada-prime
	HSKOUT := haskell-prime
	CPPOUT := cpp-prime
endif



#
# Defining targerts
#
.PHONY: clean all generate-profile use-profile fortran c java go ada rust haskell cpp

all: $(F90OUT) $(COUT) $(JAVOUT) $(GOOUT) $(ADAOUT) $(RUSTOUT) $(HSKOUT) $(CPPOUT)
fortran: $(F90OUT)
c: $(COUT)
java: $(JAVOUT)
go: $(GOOUT)
ada: $(ADAOUT)
rust: $(RUSTOUT)
haskell: $(HSKOUT)
cpp: $(CPPOUT)


#
# Defining recipies to build file types
#
$(F90OUT): $(F90OBJ)
	$(FC) $^ $(LDFLAGS) -o $@

$(COUT): $(COBJ)
	$(CC) $^ $(LDFLAGS) -o $@

$(RUSTOUT): $(RUSTSRC)
	cd $(RUST_DIR) && cargo build --release

$(JAVOUT): $(JAVSRC)
	$(JC) $^

$(GOOUT): $(GOSRC)
	$(GC) build -o $@ $^

$(ADAOUT): $(ADASRC)
	$(AC) $(ADAFLAGS) $^ -o $@

$(HSKOUT): $(HSKOBJ)
	$(HC) $(HSKFLAGS) -o $@ $^

$(CPPOUT): $(CPPOBJ)
	$(CPPC) $^ $(LDFLAGS) -o $@


$(OBJ_DIR)/%.fortran.o: $(SRC_DIR)/%.f90
	$(FC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.haskell.o: $(SRC_DIR)/%.hs
	$(HC) -c $(HSKFLAGS) $< -o $@

$(OBJ_DIR)/%.cpp.o: $(SRC_DIR)/%.cpp
	$(CPPC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(F90OBJ) $(F90OUT) $(F90ASM) $(F90MOD) $(COBJ) $(COUT) $(CASM) $(CPRE) $(CCBC) $(RUSTOUT) $(JAVOUT) $(GOOUT) $(ADAOBJ) $(ADAALI) $(ADAOUT) $(HSKOUT) $(HSKOBJ) $(HSKINT) $(CPPOBJ) $(CPPOUT) $(CPPASM) $(CPPPRE) $(CPPCBC)


#
# Stuff for profile guided optimisation
#
generate-profile: CFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: LDFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: all


use-profile: CFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: LDFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: all
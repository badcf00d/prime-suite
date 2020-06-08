FC := gfortran
CC := gcc
JC := javac
GC := go
AC := gnatmake
HC := ghc
CFLAGS := -Wall -O2 -fopenmp -march=native -fverbose-asm
LDFLAGS := -fopenmp -lm
ADAFLAGS := -Wall -O2 -march=native
HSKFLAGS := -Wall -O2 -dynamic -package time 
GEN_PROFILE_CFLAGS = -fprofile-generate -fprofile-update=single -pg
USE_PROFILE_CFLAGS = -fprofile-use -Wno-error=coverage-mismatch

SRC_DIR := .
OBJ_DIR := .
RUST_DIR := ./rust-prime
RUST_SRC_DIR := $(RUST_DIR)/src/bin
RUST_OUT_DIR := $(RUST_DIR)/target/release

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

ifeq ($(OS),Windows_NT)
	F90OUT := fortran-prime.exe
	COUT := c-prime.exe
	RUSTOUT := $(RUST_OUT_DIR)/rust-prime.exe
	GOOUT := go-prime.exe
	ADAOUT := ada-prime.exe
	HSKOUT := haskell-prime.exe
else
	F90OUT := fortran-prime
	COUT := c-prime
	RUSTOUT := $(RUST_OUT_DIR)/rust-prime
	GOOUT := go-prime
	ADAOUT := ada-prime
	HSKOUT := haskell-prime
endif

.PHONY: clean all generate-profile use-profile fortran c java go ada rust haskell

all: $(F90OUT) $(COUT) $(JAVOUT) $(GOOUT) $(ADAOUT) $(RUSTOUT) $(HSKOUT)

fortran: $(F90OUT)
c: $(COUT)
java: $(JAVOUT)
go: $(GOOUT)
ada: $(ADAOUT)
rust: $(RUSTOUT)
haskell: $(HSKOUT)


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


$(OBJ_DIR)/%.fortran.o: $(SRC_DIR)/%.f90
	$(FC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.haskell.o: $(SRC_DIR)/%.hs
	$(HC) -c $(HSKFLAGS) $< -o $@

clean:
	rm -f $(F90OBJ) $(F90OUT) $(F90ASM) $(F90MOD) $(COBJ) $(COUT) $(CASM) $(CPRE) $(CCBC) $(RUSTOUT) $(JAVOUT) $(GOOUT) $(ADAOBJ) $(ADAALI) $(ADAOUT) $(HSKOUT) $(HSKOBJ) $(HSKINT)


generate-profile: CFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: LDFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: all


use-profile: CFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: LDFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: all
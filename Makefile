FC := gfortran
CC := gcc
CFLAGS := -Wall -O2 -fopenmp -march=native -fverbose-asm
LDFLAGS := -fopenmp -lm 
GEN_PROFILE_CFLAGS = -fprofile-generate -fprofile-update=single -pg
USE_PROFILE_CFLAGS = -fprofile-use -Wno-error=coverage-mismatch

SRC_DIR := .
OBJ_DIR := .

F90SRC := $(wildcard $(SRC_DIR)/*.f90)
F90OBJ := $(F90SRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.fortran.o)
F90ASM := $(F90SRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.s)
F90MOD := $(wildcard $(SRC_DIR)/*.mod)

CSRC := $(wildcard $(SRC_DIR)/*.c)
COBJ := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.c.o)
CASM := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.s)
CPRE := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.i)
CCBC := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.bc)

ifeq ($(OS),Windows_NT)
	F90OUT := fortran-prime.exe
	COUT := c-prime.exe
else
	F90OUT := fortran-prime
	COUT := c-prime
endif

.PHONY: clean all generate-profile use-profile

all: $(F90OUT) $(COUT)
	cd rust-prime && cargo build --release

$(F90OUT): $(F90OBJ)
	$(FC) $^ $(LDFLAGS) -o $(F90OUT)

$(COUT): $(COBJ)
	$(CC) $^ $(LDFLAGS) -o $(COUT)



$(OBJ_DIR)/%.fortran.o: $(SRC_DIR)/%.f90
	$(FC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(F90OBJ) $(F90OUT) $(F90ASM) $(F90MOD) $(COBJ) $(COUT) $(CASM) $(CPRE) $(CCBC)


generate-profile: CFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: LDFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: all


use-profile: CFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: LDFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: all
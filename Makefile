FC := gfortran
CC := gcc
CFLAGS := -Wall -O2 -fopenmp -march=native -masm=intel -fverbose-asm --save-temps
LDFLAGS := -fopenmp -lm

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

.PHONY: clean all 

all: $(F90OUT) $(COUT)


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
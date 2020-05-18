FC := gfortran
CC := gcc
CFLAGS := -Wall -O2 -fopenmp -march=native -masm=intel -fverbose-asm --save-temps
LDFLAGS := -fopenmp -lm

SRC_DIR := .
OBJ_DIR := .

FORSRC := $(wildcard $(SRC_DIR)/*.f90)
FOROBJ := $(FORSRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.fort.o)
FORASM := $(FORSRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.s)
FORMOD := $(wildcard $(SRC_DIR)/*.mod)

CSRC := $(wildcard $(SRC_DIR)/*.c)
COBJ := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.c.o)
CASM := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.s)
CPRE := $(CSRC:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.i)

ifeq ($(OS),Windows_NT)
	FOROUT := fortran-prime.exe
	COUT := c-prime.exe
else
	FOROUT := fortran-prime
	COUT := c-prime
endif

.PHONY: clean all 

all: $(FOROUT) $(COUT)


$(FOROUT): $(FOROBJ)
	$(FC) $^ $(LDFLAGS) -o $(FOROUT)

$(COUT): $(COBJ)
	$(CC) $^ $(LDFLAGS) -o $(COUT)



$(OBJ_DIR)/%.fort.o: $(SRC_DIR)/%.f90
	$(FC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR)/%.c.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(FOROBJ) $(FOROUT) $(FORASM) $(FORMOD) $(COBJ) $(COUT) $(CASM) $(CPRE)
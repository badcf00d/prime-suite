FC := gfortran
FCFLAGS := -Wall -O2 -fopenmp -march=native -masm=intel --save-temps
LDFLAGS := -fopenmp

SRC_DIR := .
OBJ_DIR := .

SRC := $(wildcard $(SRC_DIR)/*.f90)
OBJ := $(SRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.o)
ASM := $(SRC:$(SRC_DIR)/%.f90=$(OBJ_DIR)/%.s)
MOD := $(wildcard $(SRC_DIR)/*.mod)
OUT := prime


.PHONY: clean all 

all: $(OUT)


$(OUT): $(OBJ)
	$(FC) $^ $(LDFLAGS) -o $(OUT)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.f90
	$(FC) $(FCFLAGS) -c $< -o $@


clean:
	rm -f $(OBJ) $(OUT) $(ASM) $(MOD)
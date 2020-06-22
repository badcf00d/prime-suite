
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
KC := kotlinc
SC := scalac

#
# Flags
#
CFLAGS := -Wall -O2 -fopenmp -march=native -fverbose-asm
LDFLAGS := -fopenmp -lm
ADAFLAGS := -Wall -O2 -march=native
HSKFLAGS := -Wall -O2 -dynamic -threaded -package parallel
KOTFLAGS := -include-runtime -jvm-target 1.8
SCAFLAGS := -deprecation
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
KOT_DIR := ./kotlin-native-prime
KOT_SRC_DIR := $(KOT_DIR)/src/commonMain/kotlin
KOT_OUT_DIR := $(KOT_DIR)/build
SCA_DIR := ./scala-prime
SCA_SRC_DIR := $(SCA_DIR)/src/main/scala
SCA_OUT_DIR := $(shell echo $(SCA_DIR)/target/scala-*)

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

KOTSRC := $(wildcard $(KOT_SRC_DIR)/*.kt)

PYSRC := $(wildcard $(SRC_DIR)/*.py)

JSSRC := $(wildcard $(SRC_DIR)/*.js)

SCASRC := $(wildcard $(SCA_SRC_DIR)/*.scala)

#
# Deciding what the executables will be called
#
ifeq ($(OS),Windows_NT)
	F90OUT := fortran-prime.exe
	COUT := c-prime.exe
	RUSTOUT := $(RUST_OUT_DIR)/prime.exe
	GOOUT := go-prime.exe
	ADAOUT := ada-prime.exe
	HSKOUT := haskell-prime.exe
	CPPOUT := cpp-prime.exe
	KOTOUT := $(KOT_OUT_DIR)/bin/windows/releaseExecutable/kotlin-native-prime.exe
	SCAOUT := $(SCA_OUT_DIR)/scala-prime-assembly-0.1.jar
else
	F90OUT := fortran-prime
	COUT := c-prime
	RUSTOUT := $(RUST_OUT_DIR)/prime
	GOOUT := go-prime
	ADAOUT := ada-prime
	HSKOUT := haskell-prime
	CPPOUT := cpp-prime
	KOTOUT := $(KOT_OUT_DIR)/bin/linux/releaseExecutable/kotlin-native-prime.kexe
	SCAOUT := $(SCA_OUT_DIR)/scala-prime-assembly-0.1.jar
endif



#
# Defining targerts
#
.PHONY: clean all generate-profile use-profile fortran c java go ada rust haskell cpp

all: $(F90OUT) $(COUT) $(JAVOUT) $(GOOUT) $(ADAOUT) $(RUSTOUT) $(HSKOUT) $(CPPOUT) $(KOTOUT) $(SCAOUT)
fortran: $(F90OUT)
c: $(COUT)
java: $(JAVOUT)
go: $(GOOUT)
ada: $(ADAOUT)
rust: $(RUSTOUT)
haskell: $(HSKOUT)
cpp: $(CPPOUT)
kotlin: $(KOTOUT)
scala: $(SCAOUT)

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

$(KOTOUT): $(KOTSRC)
ifeq ($(OS),Windows_NT)
	cd $(KOT_DIR) && gradle windowsBinaries
else
	cd $(KOT_DIR) && gradle linuxBinaries
endif

$(SCAOUT): $(SCASRC)
	cd $(SCA_DIR) && sbt assembly


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
	rm -rf $(KOT_OUT_DIR)
	rm -rf $(SCA_DIR)/target

#
# Stuff for profile guided optimisation
#
generate-profile: CFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: LDFLAGS += $(GEN_PROFILE_CFLAGS)
generate-profile: all


use-profile: CFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: LDFLAGS += $(USE_PROFILE_CFLAGS)
use-profile: all


test:
	./$(F90OUT) 1000000
	./$(COUT) 1000000
	./$(GOOUT) 1000000
	./$(ADAOUT) 1000000
	./$(HSKOUT) 1000000 +RTS -N$(shell grep -c ^processor /proc/cpuinfo)
	./$(CPPOUT) 1000000
	python3 $(PYSRC) 1000000
	node $(JSSRC) 1000000
	java $(subst ./,,$(JAVOUT:.class=)) 1000000
	scala $(SCAOUT) 1000000
	$(RUSTOUT) 1000000
	$(KOTOUT) 100

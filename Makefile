# ca65 -o obj/test.o src/test.asm
# ld65 -o bin/test.nes -C src/test.cfg obj/test.o 

CC=ca65
LD=ld65
LDFLAGS= -C src/test.cfg
SRC=src/test.asm
OBJ=obj/test.o
EXE=bin/test.nes

all:
	$(CC) -o $(OBJ) $(SRC)
	$(LD) -o $(EXE) $(LDFLAGS) $(OBJ)

clean:
	rm $(OBJ) $(EXE)

# ca65 -o obj/test.o src/test.asm
# ld65 -o bin/test.nes -C src/test.cfg obj/test.o 

CC := ca65
LD := ld65
LDFLAGS := -C src/test.cfg
SRC := src/test.asm
DEPS := src/attribtable.asm src/defs.asm src/header.asm \
	src/nametable.asm src/palette.asm src/sprite.asm src/test.chr \
	src/test2.chr
OBJ := obj/test.o
EXE := bin/test.nes

.PHONY : all clean

all: $(EXE)

$(EXE): $(OBJ)
	$(LD) -o $(EXE) $(LDFLAGS) $(OBJ)

$(OBJ): $(SRC) $(DEPS)
	$(CC) -o $(OBJ) $(SRC)

clean:
	rm $(OBJ) $(EXE)

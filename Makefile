NAME=rocket-revenge

all: rocket-revenge

clean:
	rm -rf rocket-revenge rocket-revenge.o

rocket-revenge: rocket-revenge.asm
	nasm -f elf rocket-revenge.asm
	gcc -g -m32 -o rocket-revenge rocket-revenge.o /usr/local/share/csc314/driver.c /usr/local/share/csc314/asm_io.o

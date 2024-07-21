compile:
	ca65 -l hello.lst --cpu 6502 hello.s

rom: compile
	ld65 -C hello.cfg hello.o
	hexdump -v -e '16/1 "%02x " "\n"' hello.bin > hello.mem

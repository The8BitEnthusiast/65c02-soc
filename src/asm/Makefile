compile:
	ca65 -l wozmon.lst --cpu 65C02 wozmon.s

rom: compile
	ld65 -C wozmon.cfg wozmon.o
	hexdump -v -e '16/1 "%02x " "\n"' wozmon.bin > wozmon.mem

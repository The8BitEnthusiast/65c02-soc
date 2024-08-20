# 6502 System-on-Chip (SoC)

![Splash](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/Pictures/overview.png?raw=true)

This project explores the use of FPGA technology to implement a fully functional 6502 computer. My primary goal was to deep dive into I/O ICs like the 65C22 VIA and 65C51 ACIA and replicate their functionality. Sources of inspiration are:
* Ben Eater's [6502 breadboard computer video series](https://eater.net/6502), which provided the canvas for the overall design 
* This [FPGA SoC prototyping book](https://www.wiley.com/en-us/FPGA+Prototyping+by+SystemVerilog+Examples%3A+Xilinx+MicroBlaze+MCS+SoC+Edition-p-9781119282709), which I've used to learn more about System on Chip architecture and, more specifically, memory mapped I/O.

Features include:
* Arlet Otten's [65C02 soft core](https://github.com/Arlet/verilog-65C02-microcode) as the microprocessor
* Block memory based ROM and RAM modules
* A memory mapped I/O subsystem that includes the following I/O cores:
    * An emulated 65C22 Versatile Interface Adapter (VIA)
    * An emulated 65C51 Asynchronous Communications Interface Adapter 

## Design

This project reproduces Ben Eater's 6502 breadboard computer design. A functional overview is shown below.

![Overview](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/Graphics/DesignOverview.png?raw=true)

For the 65C02 soft core, Arlet Otten's implementation is really well made and it is designed to work with synchronous memory such as those typically available in FGPA (block RAM). So I haven't been tempted to build one from scratch.

The ROM and RAM modules are implemented as Block Memory. At first I used memory IP from Vivado's IP Catalog (my FPGA toolchain), but then, after sifting throught the documentation, I learned that Vivado will infer Block Memory if the Verilog module adheres to a specific structure.

The 65C22 Via module has for now just enough functionality to allow Ben's code samples to run. It has the first four registers (PORTB, PORTA, DDRB, DDRA) implemented, and the bi-directional I/O pins have been successfully tested with an LCD display.

The memory map implemented on the project, as shown below is consistent with Ben's design.

![MemoryMap](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/memorymap/memorymap.png?raw=true)

For the serial communications soft core, I took a deep dive into the 65C51 ACIA's architecture and managed to replicate enough of its functionality to allow Ben's version of MS-Basic to run natively on my 6502 SoC project. Features supported so far:

- Programmable baud rate
- Interrupts on receive
- Buffered transmit and receive
- Hardware flow control (RTS and CTS)
- No transmision bug - the status register tells you if the transmission queue has room or not

Not duplicating the WDC 65C51's transmission status 'bug' has allowed me to modify Ben's transmission code to check the tx status flag instead of generating a delay. I also incorporated the LCD routines to his BIOS to help with troubleshooting when the serial interface did not cooperate. Very handy.

To establish serial communications between the FPGA board and a computer, I used this [LCD234X USB to UART module](https://ftdichip.com/wp-content/uploads/2020/07/DS_LC234X.pdf) made by FTDI. There are plenty of other alternatives that perform the same function out there.


## Hello World Performance Tests

I was curious to know how fast Ben's "Hello World" code would run in this setup. For initial rounds of tests, and to make debugging manageable, I initially drove the implemented modules with an external clock. The only change I had made to Ben's code at that point was to implement the LCD's initialization by instruction as prescribed in the data sheet, which mostly consisted of adding a delay between init commands. I quickly got to the maximum frequency my function generator could produce, 4Mhz, with no issue at all.

Once the functionality was proven to work fairly reliability, I switched to the FPGA's internal clock (50 Mhz) and tested the design at different clock frequencies. As the results below show, the circuit started to struggle between 20 and 30 Mhz.

![TestResults](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/Graphics/TestResults.png?raw=true)

I initially thought I was hitting the limit of breadboard I/O bandwidth, but no, it turned out that the root cause was that the Enable pulse width, which is bit-banged through the VIA with code, ended up falling below specification, i.e. <450ns. Adding a small delay to extend the pulse width solved the issue and the program ran successfully right up to 50 Mhz.

## Next Steps

VGA output is next on the radar. I had already replicated Ben's VGA circuit on my FPGA board in a [previous experiment](https://github.com/The8BitEnthusiast/vga-on-fpga). For the next round, I intend to expand its capabilities with higher resolutions and explore how sprites work.


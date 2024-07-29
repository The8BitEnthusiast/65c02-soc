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
    * (On the roadmap) Serial interface (code compatible with the 65C51 ACIA)

## Design

This project reproduces Ben Eater's 6502 breadboard computer design. A functional overview is shown below.

![Overview](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/Graphics/DesignOverview.png?raw=true)

For the 65C02 soft core, Arlet Otten's implementation is really well made and it is designed to work with synchronous memory such as those typically available in FGPA (block RAM). So I haven't been tempted to build one from scratch.

The ROM and RAM modules are implemented as Block Memory. At first I used memory IP from Vivado's IP Catalog (my FPGA toolchain), but then, after sifting throught the documentation, I learned that Vivado will infer Block Memory if the Verilog module adheres to a specific structure.

The 65C22 Via module has for now just enough functionality to allow Ben's Hello World code to run. It has the first four registers (PORTB, PORTA, DDRB, DDRA) implemented, and the bi-directional I/O pins have been successfully tested with an LCD display.

The memory map implemented on the project, as shown below is consistent with Ben's design.

![MemoryMap](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/memorymap/memorymap.png?raw=true)

## Performance Tests

I was curious to know how fast Ben's "Hello World" code would run in this setup. For initial rounds of tests, and to make debugging manageable, I initially drove the implemented modules with an external clock. The only change I had made to Ben's code at that point was to implement the LCD's initialization by instruction as prescribed in the data sheet, which mostly consisted of adding a delay between init commands. I quickly got to the maximum frequency my function generator could produce, 4Mhz, with no issue at all.

Once the functionality was proven to work fairly reliability, I switched to the FPGA's internal clock (50 Mhz) and tested the design at different clock frequencies. As the results below show, the circuit started to struggle between 20 and 30 Mhz.

![TestResults](https://github.com/The8BitEnthusiast/65c02-soc/blob/main/images/Graphics/TestResults.png?raw=true)

I initially thought I was hitting the limit of breadboard I/O bandwidth, but no, it turned out that the root cause was that the Enable pulse width, which is bit-banged through the VIA with code, ended up falling below specification, i.e. <450ns. Adding a small delay to extend the pulse width solved the issue and the program ran successfully right up to 50 Mhz.

## Next Steps

Serial communications is next with an emulation of the 65C51 ACIA. Also looking forward to running Wozmon and MS-Basic at 50Mhz! ;-)

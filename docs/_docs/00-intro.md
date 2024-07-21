---
title: "6502 System-on-Chip (SoC)"
permalink: /
excerpt: "Exploration of FPGA technology to implement a fully functional 6502 computer"
---

This project was aimed at exploring the use of FPGA technology to implement a fully functional 6502 computer. The primary sources of inspiration were:
* Ben Eater's [6502 breadboard computer video series](https://eater.net/6502) 
* This [FPGA SoC prototyping book](https://www.wiley.com/en-us/FPGA+Prototyping+by+SystemVerilog+Examples%3A+Xilinx+MicroBlaze+MCS+SoC+Edition-p-9781119282709), which was used as the basis for the overall design

Features include:
* Arlet Otten's [65C02 soft core](https://github.com/Arlet/verilog-65C02-microcode) as the microprocessor
* A memory mapped I/O subsystem that includes the following I/O cores:
    * An emulated 65C22 Versatile Interface Adapter (VIA)
    * Serial interface (code compatible with the 65C51 ACIA)

## Design

The design goes here

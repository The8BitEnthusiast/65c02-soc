module top (
    input clk, 
    input RST, 
    inout [7:0] pa,
    inout [7:0] pb,
    input rx, 
    output tx);

    wire [7:0] DO;
    wire [7:0] DI;
    wire [15:0] AD;
    wire WE;
    reg  [15:0] ADB;
    wire ram_ena, ram_enb;
    // wire sync;
    
    wire [7:0] rom_dout;
    wire [7:0] ram_dob;
    // wire [7:0] ram_doutb;
    //
    wire reset_pwr, reset_int;
    wire irq_acia, irq;

    // Power-on reset module (generates a delayed reset pulse)
    reset rst0 (.clk(clk), .rst(reset_pwr));
    assign reset_int = reset_pwr || RST; 
    assign irq = irq_acia; // only interrupt source is ACIA for now

    cpu cpu0 (.clk(clk), .RST(reset_int), .AD(AD), .sync(sync), 
                .DI(DI), .DO(DO), 
                .WE(WE), .IRQ(irq), .NMI(1'b0), .RDY(1'b1), .debug(1'b1));

    // ROM 
    rom rom0 (
        .clk(clk),    // input wire clk
        .addr(AD[14:0]),  // input wire [14 : 0] addr
        .dout(rom_dout)  // output wire [7 : 0] douta
    );

    // RAM
    ram ram0 (
        .clk(clk),
        .ena(ram_ena),
        .addra(ADB[13:0]),
        .wea(WE),
        .dia(DO),
        .enb(ram_enb),
        .addrb(AD[13:0]),
        .dob(ram_dob)
    );

    assign ram_ena = (ADB<16'h5000) ? 1'b1 : 1'b0;
    assign ram_enb = (AD<16'h5000) ? 1'b1 : 1'b0;

    // instantiate I/O controller #0
    wire mmio0_cs;
    assign mmio0_cs = (ADB[15:12]) == 4'h6 ? 1 : 0;
    mmio_controller mmio0 (
        .clk(clk),
        .rst(reset_int),
        .mmio_cs(mmio0_cs),
        .mmio_we(WE),
        .mmio_addr(ADB[11:0]),
        .mmio_wr_data(DO)
    );

    // create via and attach it to slot #0 (address $6000)
    // of IO controller
    via via0 (
        .clk(clk),
        .rst(reset_int),
        .rs(mmio0.slot_reg_addr_array[0][3:0]),
        .we(mmio0.slot_mem_we_array[0]),
        .en(mmio0.slot_cs_array[0]),
        .din(mmio0.slot_wr_data_array[0]),
        .dout(mmio0.slot_rd_data_array[0]),
        .pa(pa),
        .pb(pb)
    );

    // instantiate I/O controller #1 : Attached to memory block $5000
    wire mmio1_cs;
    assign mmio1_cs = (ADB[15:12]) == 4'h5 ? 1 : 0;
    mmio_controller mmio1 (
        .clk(clk),
        .rst(reset_int),
        .mmio_cs(mmio1_cs),
        .mmio_we(WE),
        .mmio_addr(ADB[11:0]),
        .mmio_wr_data(DO)
    );

    // create ACIA and attach it to slot #0 (address $5000)
    // of IO controller
    acia acia0 (
        .clk(clk),
        .rst(reset_int),
        .rs(mmio1.slot_reg_addr_array[0][1:0]),
        .we(mmio1.slot_mem_we_array[0]),
        .en(mmio1.slot_cs_array[0]),
        .din(mmio1.slot_wr_data_array[0]),
        .dout(mmio1.slot_rd_data_array[0]),
        .tx(tx),
        .rx(rx),
        .irq(irq_acia)
    );

    // drive the data in bus using this memory map:
    //   $8000 - $FFFF : ROM (32K)
    //   $6000 - $6FFF : I/O Controller #0
    //   $0000 - $5FFF : RAM (16K)
    assign DI = (ADB>=16'h8000) ? rom_dout : 
                (ADB[15:12] == 4'h6) ? mmio0.mmio_rd_data :
                (ADB[15:12] == 4'h5) ? mmio1.mmio_rd_data :
                ram_dob;
                // (ADB>=16'h6000) ? DB :
                // ram_doutb;
    
    // since WE is active high, the external RW pin is inverted
    // assign RW = ~WE;

    // set up external address bus pins
    always @ (posedge clk)
    begin
        ADB <= AD;
    end

    // assign DB = WE ? DO : 8'hZZ;


endmodule

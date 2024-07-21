module top (input clk, input RST, output sync);

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

    cpu cpu0 (.clk(clk), .RST(RST), .AD(AD), .sync(sync), 
                .DI(DI), .DO(DO), 
                .WE(WE), .IRQ(1'b0), .NMI(1'b0), .RDY(1'b1), .debug(1'b1));

    // ROM 
    rom rom0 (
        .clk(clk),    // input wire clk
        .addr(AD[14:0]),  // input wire [14 : 0] addr
        .dout(rom_dout)  // output wire [7 : 0] douta
    );

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

    // drive the data in bus using this memory map:
    //   $8000 - $FFFF : ROM
    //   $6000 - $7FFF : External I/O
    //   $0000 - $5FFF : RAM
    assign DI = (ADB>=16'h8000) ? rom_dout : 
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

`timescale 1ns/1ps

module cpu_simpleEA_tb();

    logic clk;
    logic [7:0] DO;
    logic [7:0] DI;
    logic [15:0] AD;
    logic IRQ;
    logic NMI;
    logic RDY;
    logic WE;
    logic RST; 
    logic sync;
    logic debug;

    cpu DUT (.clk(clk), .RST(RST), .AD(AD), .sync(sync), 
                .DI(DI), .DO(DO), 
                .WE(WE), .IRQ(IRQ), .NMI(NMI), .RDY(RDY), .debug(debug));          
    
    always
    begin
        #10 clk <= ~clk;
    end

    initial
    begin
        clk <= 1'b0;
        RST <= 1'b1;
        debug <= 1'b1;
        DI <= 8'hEA; // hard-code EA on inbound data bus
        IRQ <= 1'b1;
        NMI <= 1'b1;
        RDY <= 1'b1;
        
        // take CPU out of reset
        #200 RST <= 1'b0;
    end


endmodule

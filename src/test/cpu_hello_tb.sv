`timescale 1ns/1ps

module cpu_hello_tb();

    logic clk;
    logic RST = 0; 
    logic [7:0] pb_in;
    logic [7:0] pa_in;
    logic pb_dir;
    wire [7:0] pb;
    logic pa_dir;
    wire [7:0] pa;
    reg rx;
    wire tx;

    assign pb = (pb_dir == 0) ? pb_in : 8'bZZZZZZZZ;
    assign pa = (pa_dir == 0) ? pa_in : 8'bZZZZZZZZ;

    top DUT (.clk(clk), .RST(RST), .pb(pb), .pa(pa), .tx(tx), .rx(rx));
    
    always
    begin
        #10 clk <= ~clk;
    end

    initial
    begin
        clk <= 1'b0;
        // RST <= 1'b1;
        pb_dir = 1;
        pa_dir = 1;
        rx = 1;
        
        // take CPU out of reset
        // #200 RST <= 1'b0;

        // wait for LCD enable pulse
        /*
        wait (pa[7:5] == 3'b010);
        pb_dir = 0;
        pb_in = 8'b10000000; // simulate busy flag
        @ (negedge pa[7])
        begin
            pb_dir = 1;
        end
        */

    // you need to adjust the delays that follow below in 
    // accordance with the baud rate set for the ACIA
    #1_500_000

    rx = 0;      // start bit
    #52083
    rx = 0;
    #52083
    rx = 0;
    #52083
    rx = 0;
    #52083
    rx = 0;
    #52083
    rx = 1;
    #52083
    rx = 1;
    #52083
    rx = 0;
    #52083
    rx = 0;
    #52083
    rx = 1;     // stop bit

    end

endmodule

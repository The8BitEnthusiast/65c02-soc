`timescale 1ns/1ps

module cpu_hello_tb();

    logic clk;
    logic RST; 
    logic [7:0] pb_in;
    logic [7:0] pa_in;
    logic pb_dir;
    wire [7:0] pb;
    logic pa_dir;
    wire [7:0] pa;

    assign pb = (pb_dir == 0) ? pb_in : 8'bZZZZZZZZ;
    assign pa = (pa_dir == 0) ? pa_in : 8'bZZZZZZZZ;

    top DUT (.clk(clk), .RST(RST), .pb(pb), .pa(pa));
    
    always
    begin
        #10 clk <= ~clk;
    end

    initial
    begin
        clk <= 1'b0;
        RST <= 1'b1;
        pb_dir = 1;
        pa_dir = 1;
        
        // take CPU out of reset
        #200 RST <= 1'b0;

        wait (pa[7:5] == 3'b010);
        pb_dir = 0;
        pb_in = 8'b10000000; // simulate busy flag
        @ (negedge pa[7])
        begin
            pb_dir = 1;
        end
    end

endmodule

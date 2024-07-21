`timescale 1ns/1ps

module cpu_hello_tb();

    logic clk;
    logic RST; 

    top DUT (.clk(clk), .RST(RST));
    
    always
    begin
        #10 clk <= ~clk;
    end

    initial
    begin
        clk <= 1'b0;
        RST <= 1'b1;
        
        // take CPU out of reset
        #200 RST <= 1'b0;
    end


endmodule

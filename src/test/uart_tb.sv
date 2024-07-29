`timescale 1ns / 1ps
module uart_tb ();

logic clk, reset;
logic rd_uart, wr_uart, rx;
logic [7:0] w_data;
logic [10:0] dvsr;
logic tx_full, rx_empty, tx;
logic [7:0] r_data;

uart DUT(.*);

always
    #10 clk = ~clk;

initial
begin
    clk = 0;
    dvsr = 26; // divisor for 115,200 baud rate with 50Mhz clock
    w_data = 8'hEA;
    rd_uart = 0;
    wr_uart = 0;
    reset = 0;
    rx = 1;

    #100 reset = 1;
    #20  reset = 0;

    @(negedge clk)
        wr_uart = 1;

    @(negedge clk)
        wr_uart = 0;

    #100000

    rx = 0;      // start bit
    #8681
    rx = 1;
    #8681
    rx = 0;
    #8681
    rx = 1;
    #8681
    rx = 1;
    #8681
    rx = 0;
    #8681
    rx = 1;
    #8681
    rx = 0;
    #8681
    rx = 1;
    #8681
    rx = 1;     // stop bit

    #40000;
    @(posedge clk)
        rd_uart = 1;
    @(posedge clk)
        rd_uart = 0;


    // #50000 $finish;
end

endmodule

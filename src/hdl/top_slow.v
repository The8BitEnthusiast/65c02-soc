module top_slow (
    input clk,
    input RST,
    inout [7:0] pa,
    inout [7:0] pb
);

    wire clk_out;
    wire locked;

    clk_wiz_0 instance_name
    (
        // Clock out ports
        .clk_out1(clk_out),     // output clk_out1
        // Status and control signals
        .locked(locked),       // output locked
        // Clock in ports
        .clk_in1(clk)      // input clk_in1
    );

    top(.clk(clk_out), .RST(RST), .pa(pa), .pb(pb));

endmodule


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

    localparam BAUD_RATE = 19_200;
    localparam PERIOD = 10**9 / BAUD_RATE;

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

    // give time to Wozmon to send the backslash
    /*
    #(PERIOD*8*5);

    receive_char("8");
    #(PERIOD*8*1);
    receive_char("0");
    #(PERIOD*8*1);
    receive_char("0");
    #(PERIOD*8*1);
    receive_char("0");
    #(PERIOD*8*1);
    receive_char("R");
    #(PERIOD*8*1);
    receive_char(8'h0D);
    #(PERIOD*8*1);

    // hit enter after receiving "MEMORY SIZE?"
    #(PERIOD*8*25);
    receive_char(8'h0D);
    */

    end

    task receive_char(input [7:0] char);
    
        integer i;
        begin
            rx = 0;    // start bit
            #PERIOD;
            for (i = 0; i <=7; i=i+1)
            begin
                rx = char[i];
                #PERIOD;
            end
            rx = 1;   // stop bit
            #PERIOD;
        end

    endtask

endmodule

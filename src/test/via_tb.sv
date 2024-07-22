module via_tb ();

reg clk, en, we, RST;
reg [3:0] rs;
wire [7:0] pb;
wire [7:0] pa;
reg [7:0] din; 
reg [7:0] pa_in;
reg pa_dir;
reg [7:0] pb_in;
reg pb_dir;
wire [7:0] dout;

via DUT (.clk(clk),
         .rst(RST),
         .en(en),
         .we(we),
         .rs(rs),
         .din(din),
         .dout(dout),
         .pb(pb),
         .pa(pa));

assign pa = (pa_dir == 0) ? pa_in : 8'bZZZZZZZZ;
assign pb = (pb_dir == 0) ? pb_in : 8'bZZZZZZZZ;

initial
begin

    /* RESET */
    clk = 0;
    RST = 0;

    #10
    RST = 1;

    #10
    RST = 0;
    
    /* PORT B Testing */

    #10
    clk = 0;
    rs = 4'b0010; // target DDRB
    din = 8'b00000000; // set all PB pins to inputs
    we = 1;
    en = 1;

    #10 clk = 1;

    #10 clk = 0;
    pb_dir = 0;
    pb_in = 8'b01010101;
    we = 0;
    rs = 4'b0000; // target pb input

    #10 clk = 1;

    #10 clk = 0;
    rs = 4'b0010; // target DDRB
    pb_dir = 1; // set pb driver direction to high impedance
    din = 8'b11111111; // set all PB pins to outputs
    we = 1; // enable write

    #10 clk = 1;

    #10 clk = 0;
    rs = 4'b0000; // target ORB
    we = 1;
    din = 8'b10101010;

    #10 clk = 1;

    /* PORT A Testing */
    
    #10
    clk = 0;
    rs = 4'b0011; // target DDRA
    din = 8'b00000000; // set all PA pins to inputs
    we = 1;
    en = 1;

    #10 clk = 1;

    #10 clk = 0;
    pa_dir = 0; // enable pa driver
    pa_in = 8'b01100110; // set pa input to $66
    we = 0;
    rs = 4'b0001; // target pa input 

    #10 clk = 1;

    #10 clk = 0;
    rs = 4'b0011; // target DDRA
    pa_dir = 1; // set pa driver direction to high impedance
    din = 8'b11111111; // set all PA pins to outputs
    we = 1; // enable write

    #10 clk = 1;

    #10 clk = 0;
    rs = 4'b0001; // target ORA
    we = 1;
    din = 8'b11101110; // write $EE

    #10 clk = 1;

    #10 clk = 0;
    we = 0;

end

endmodule

module acia (
    input clk,
    input rst,
    input [1:0] rs,
    input we,
    input en,
    input [7:0] din,
    output [7:0] dout,
    output tx,
    input rx
);

localparam CLK_FREQ = 50_000_000;  // FPGA internal clock frequency

wire rd_uart, wr_uart, rx_empty, tx_full;
wire [7:0] r_data, w_data;
wire [7:0] status;

reg [7:0] ctrl_reg = 8'h00;    // control register
wire [20:0] dvsr;   // clock divisor for baud rate generator

// assign the appropriate divisor based on selected baud rate
assign dvsr = (ctrl_reg[3:0] == 4'b0000) ? (CLK_FREQ / (115_200 * 16)) - 1 :
              (ctrl_reg[3:0] == 4'b0001) ? (CLK_FREQ / (50 * 16)) - 1 :
              (ctrl_reg[3:0] == 4'b1110) ? (CLK_FREQ / (9_600 * 16)) - 1 :
              (ctrl_reg[3:0] == 4'b1111) ? (CLK_FREQ / (19_200 * 16)) - 1 :
              (CLK_FREQ / (115_200 * 16)) - 1; 

uart uart0 (
    .clk(clk), 
    .reset(rst),
    .rd_uart(rd_uart), 
    .wr_uart(wr_uart), 
    .rx(rx),
    .w_data(w_data),
    .dvsr(dvsr), 
    .tx_full(tx_full), 
    .rx_empty(rx_empty), 
    .tx(tx),
    .r_data(r_data)
);

assign rd_uart = (en && !we && rs == 2'b00) ? 1'b1 : 1'b0;
assign wr_uart = (en && we && rs == 2'b00) ? 1'b1 : 1'b0;
assign w_data = din;
assign status = {3'b000, ~tx_full, ~rx_empty, 3'b000};

assign dout = (rs == 2'b00) ? r_data :
            (rs == 2'b01) ? status :
            (rs == 2'b10) ? 8'h00 :
            (rs == 2'b11) ? ctrl_reg : 8'h00 ;


always @(posedge clk, posedge rst)
begin
    if (rst)
        ctrl_reg <= 8'h00;
    else
    begin
        if (en)
        begin
            if (we)
            begin
                case (rs)
                    2'b00: ;
                    2'b01: ;
                    2'b10: ;
                    2'b11: ctrl_reg <= din;
                    default: ;
                endcase
            end
        end
    end
end


endmodule

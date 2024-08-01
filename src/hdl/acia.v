module acia (
    input clk,
    input rst,
    input [1:0] rs,
    input we,
    input en,
    input [7:0] din,
    output [7:0] dout,
    output tx,
    input rx,
    output irq
);

localparam CLK_FREQ = 50_000_000;  // FPGA internal clock frequency

wire rd_uart, wr_uart, rx_done_tick, rx_empty, tx_full;
wire [7:0] r_data, w_data;
wire [7:0] status;
reg int_flag = 0;   // interrupt flag

reg [7:0] ctrl_reg = 8'h00;    // control register
reg [7:0] cmd_reg = 8'h00;     // command register

wire [20:0] dvsr;   // clock divisor for baud rate generator

// bit 1 of command register must be cleared to enable receive interrupts
// assign irq = rx_done_tick & ~cmd_reg[1];
assign irq = int_flag;

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
    .r_data(r_data),
    .rx_done_tick(rx_done_tick)
);

assign rd_uart = (en && !we && rs == 2'b00) ? 1'b1 : 1'b0;
assign wr_uart = (en && we && rs == 2'b00) ? 1'b1 : 1'b0;
assign w_data = din;
assign status = {int_flag, 2'b00, ~tx_full, ~rx_empty, 3'b000};

assign dout = (rs == 2'b00) ? r_data :
            (rs == 2'b01) ? status :
            (rs == 2'b10) ? cmd_reg :
            (rs == 2'b11) ? ctrl_reg : 8'h00 ;


always @(posedge clk, posedge rst)
begin
    if (rst)
    begin
        ctrl_reg <= 8'h00;
        int_flag <= 1'b0;
    end
    else
    begin
        if (rx_done_tick && ~cmd_reg[1])
            int_flag <= 1'b1;
        if (en)
        begin
            if (we) // write operations
            begin
                case (rs)
                    2'b00: ; // direct pass through to UART module
                    2'b01: ; // programmed reset - not implemented 
                    2'b10: cmd_reg <= din;
                    2'b11: ctrl_reg <= din;
                    default: ;
                endcase
            end
            else // read operations
            begin
                case (rs)
                    2'b00: ;
                    2'b01: int_flag <= 1'b0 ; // clear int flag
                    2'b10: ;
                    2'b11: ;
                    default: ;
                endcase
            end
        end
    end
end


endmodule

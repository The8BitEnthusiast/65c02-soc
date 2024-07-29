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

wire rd_uart, wr_uart, rx_empty, tx_full;
wire [7:0] r_data, w_data;
wire [7:0] status;

uart uart0 (
    .clk(clk), 
    .reset(rst),
    .rd_uart(rd_uart), 
    .wr_uart(wr_uart), 
    .rx(rx),
    .w_data(w_data),
    .dvsr(26), // hard coded for 115,200 bps for now
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
            (rs == 2'b11) ? 8'h00 : 8'h00 ;

/*
always @(posedge clk, posedge rst)
begin
    if (rst)
    begin
        // ddrb <= 8'b00000000; // set all PB pins to inputs
        // ddra <= 8'b00000000; // set all PA pins to inputs
    end
    else
    begin
        if (en)
        begin
            if (we)
            begin
                case (rs)
                    4'b0000: orb <= din;
                    4'b0001: ora <= din;
                    4'b0010: ddrb <= din;
                    4'b0011: ddra <= din;
                    default: nothing <= din;
                endcase
            end
        end
    end
end
*/

endmodule

module via (
    input clk,
    input rst,
    input [3:0] rs,
    input we,
    input en,
    input [7:0] din,
    output [7:0] dout,
    inout [7:0] pb,
    inout [7:0] pa
);

reg [7:0] orb, irb, ora, ira, ddrb, ddra, nothing;

assign dout = (rs == 4'b0000) ? pb :
            (rs == 4'b0001) ? pa :
            (rs == 4'b0010) ? ddrb :
            (rs == 4'b0011) ? ddra :
            8'bxxxxxxxx;

always @(posedge clk, posedge rst)
begin
    if (rst)
    begin
        ddrb <= 8'b00000000; // set all PB pins to inputs
        ddra <= 8'b00000000; // set all PA pins to inputs
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
            /* input latching not supported yet */
            /*
            else
            begin
                case (rs)
                    4'b0000: irb <= pb;
                    4'b0001: ira <= pa;
                    default: nothing <= 0;
                endcase
            end
            */
        end
    end
end

assign pb[0] = (ddrb[0] == 1) ? orb[0] : 1'bZ;
assign pb[1] = (ddrb[1] == 1) ? orb[1] : 1'bZ;
assign pb[2] = (ddrb[2] == 1) ? orb[2] : 1'bZ;
assign pb[3] = (ddrb[3] == 1) ? orb[3] : 1'bZ;
assign pb[4] = (ddrb[4] == 1) ? orb[4] : 1'bZ;
assign pb[5] = (ddrb[5] == 1) ? orb[5] : 1'bZ;
assign pb[6] = (ddrb[6] == 1) ? orb[6] : 1'bZ;
assign pb[7] = (ddrb[7] == 1) ? orb[7] : 1'bZ;

assign pa[0] = (ddra[0] == 1) ? ora[0] : 1'bZ;
assign pa[1] = (ddra[1] == 1) ? ora[1] : 1'bZ;
assign pa[2] = (ddra[2] == 1) ? ora[2] : 1'bZ;
assign pa[3] = (ddra[3] == 1) ? ora[3] : 1'bZ;
assign pa[4] = (ddra[4] == 1) ? ora[4] : 1'bZ;
assign pa[5] = (ddra[5] == 1) ? ora[5] : 1'bZ;
assign pa[6] = (ddra[6] == 1) ? ora[6] : 1'bZ;
assign pa[7] = (ddra[7] == 1) ? ora[7] : 1'bZ;

endmodule

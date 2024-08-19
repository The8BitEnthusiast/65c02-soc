module rom (
    input clk,
    input [14:0] addr,
    output reg [7:0] dout );

reg [7:0] mem [32767:0];

initial
    $readmemh("eater.mem", mem);

always @(posedge clk)
begin
    dout <= mem[addr];
end

endmodule

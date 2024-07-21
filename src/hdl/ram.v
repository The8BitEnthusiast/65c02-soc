module ram (
    input clk,
    input wea,
    input ena,
    input enb,
    input [13:0] addra,
    input [13:0] addrb,
    input [7:0] dia,
    output reg [7:0] dob );

reg [7:0] mem [16383:0];

always @(posedge clk)
begin
    if (ena)
    begin
        if (wea)
        begin
            mem[addra] <= dia;
        end
    end
end

always @(posedge clk)
begin
    if (enb)
        dob <= mem[addrb];
end

endmodule

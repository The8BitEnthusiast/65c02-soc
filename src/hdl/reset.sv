module reset (
    input logic clk,
    output logic rst
);

logic [7:0] counter = 0;

typedef enum {s0, s1, s2} state_type;

state_type state_reg, state_next;

always_ff @(posedge clk)
begin
    state_reg <= state_next;
    counter <= counter + 1;
end

// next-state logic
always_comb
begin
    case(state_reg)
        s0:
            if (counter == 100)
                state_next = s1;
            else
                state_next = s0;
        s1:
            if (counter == 200)
                state_next = s2;
            else
                state_next = s1;
        s2:
            state_next = s2;
        default:
            state_next = s0;
    endcase
end

// Moore outputs
assign rst = (state_reg == s1) ? 1'b1 : 1'b0;

endmodule

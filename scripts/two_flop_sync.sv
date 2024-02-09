module two_flop_sync(
input logic clk,
input logic rst,
input logic signal_i,
output logic signal_o
);
logic [1:0] s_reg;
always_ff @(posedge clk) begin
if (rst)
s_reg <= 2'b00;
else begin
s_reg[1] <= s_reg[0];
s_reg[0] <= signal_i;
end
end
assign signal_o = s_reg[1];
endmodule
module edge_detector(
 input logic clk,
 input logic rst,
 input logic vsync,
 output logic move_enable
);
 logic [1:0] s_reg;
always_ff @(posedge clk) begin
 if (rst)
 s_reg <= 2'b11;
 else begin
 s_reg[1] <= s_reg[0];
 s_reg[0] <= vsync;
 end
 end
 assign move_enable = s_reg[1] & ~s_reg[0];
endmodule
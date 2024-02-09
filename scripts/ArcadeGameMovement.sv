module ArcadeGameMovement(input clk, input rst, input logic P_Up, input logic P_Dn,  
		  	input logic[10:0] P_upper_limit, input logic[10:0] P_down_limit,
		  	output logic move_up, output logic move_down);
	
	logic PUP,PDOWN;
	two_flop_sync MUP(clk, rst, P_Up, PUP);	
	two_flop_sync MDN(clk, rst, P_Dn, PDOWN);

	assign move_up = (PUP && (!PDOWN)) && (P_upper_limit - 165 >= 5);
	assign move_down = (PDOWN && (!PUP)) && (434 - P_down_limit >= 5);

endmodule	
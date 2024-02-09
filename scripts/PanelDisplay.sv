module PanelDisplay (
input logic clk,
input logic rst,
input logic play,
input logic BTNU,
input logic BTND,
input logic BTNL,
input logic BTNR,
output logic hsync,
output logic vsync,
output logic [3:0] red,
output logic [3:0] green,
output logic [3:0] blue,
output logic [11:0] score);

logic pxlClk;
logic [10:0] rows_count,cols_count;
logic [3:0] min, max;
logic move_enable;
logic [10:0] bound_upper_limit, bound_down_limit, bound_left_limit, bound_right_limit;

//clock 
always_ff @(posedge clk) begin
	if (rst)
	  pxlClk <= 1'b1;
	else
	  pxlClk <= ~pxlClk;	
end

assign max = 4'b1111;
assign min = 4'b0000;
assign bound_upper_limit = 165;
assign bound_down_limit = 434;
assign bound_left_limit = 215;
assign bound_right_limit = 584;

edge_detector DUT1(clk, rst, vsync, move_enable);

logic [10:0] stepx, stepy;
logic [10:0] sq_upper_limit, sq_down_limit, sq_right_limit, sq_left_limit;

logic [10:0] P1_paddle_upper_limit, P1_paddle_down_limit;
logic [10:0] P2_paddle_upper_limit, P2_paddle_down_limit;
logic P1_move_up, P1_move_down;
logic P2_move_up, P2_move_down;

logic hasScored;
logic won;
//change of ball coordinates
always_ff @(posedge clk) begin
	if(rst || won) begin		
	  	sq_upper_limit <= 289;
	  	sq_down_limit <= 310;
	  	sq_left_limit <= 389;
	  	sq_right_limit <= 410;
	  	stepx <= 5;
	  	stepy <= 5;
	  	hasScored <= 0;
	  	score <= 0;
	end
	
	else if(hasScored && pxlClk) begin
		stepx <= -stepx;
		sq_upper_limit <= 289;
	  	sq_down_limit <= 310;
	  	sq_left_limit <= 389;
	  	sq_right_limit <= 410;
	  	hasScored <= 0;
	end
		
	else if(play && pxlClk) begin
		if(move_enable) begin
			//y axis
			//o tetragonos vrike tavani
			if((sq_upper_limit - bound_upper_limit) < 5 || (sq_right_limit >= bound_right_limit && (sq_upper_limit - P2_paddle_down_limit < 5)) || (bound_left_limit >= sq_left_limit && (sq_upper_limit - P1_paddle_down_limit < 5)))
				stepy <= 5;
			//o tetragonos vrike pato
			else if(bound_down_limit - sq_down_limit < 5 || (sq_right_limit >= bound_right_limit && (P2_paddle_upper_limit - sq_down_limit < 5)) || (bound_left_limit >= sq_left_limit && (P1_paddle_upper_limit - sq_down_limit < 5)))
				stepy <= -5;
			//x axis
			if((sq_left_limit - bound_left_limit < 5) && (sq_down_limit>=P1_paddle_upper_limit && sq_upper_limit<=P1_paddle_down_limit))
				stepx <= 5;
			else if((bound_right_limit - sq_right_limit < 5) && (sq_down_limit>=P2_paddle_upper_limit && sq_upper_limit<=P2_paddle_down_limit))
				stepx <= -5;

			sq_upper_limit <= sq_upper_limit + stepy;
			sq_down_limit <= sq_down_limit + stepy;
			sq_left_limit <= sq_left_limit + stepx;
			sq_right_limit <= sq_right_limit + stepx;
		end	
		if(sq_left_limit > 600) begin
			score[11:6] <= score[11:6] + 1;
			hasScored <= 1;
		end
		//P2 Scored
		else if(sq_right_limit < 199) begin
			score[5:0] <= score[5:0] + 1;
			hasScored <= 1 ;
		end	
	  
	end
end		


ArcadeGameMovement P1(clk,rst,BTNU,BTNL,P1_paddle_upper_limit,P1_paddle_down_limit, P1_move_up, P1_move_down);
ArcadeGameMovement P2(clk,rst,BTNR,BTND,P2_paddle_upper_limit,P2_paddle_down_limit, P2_move_up, P2_move_down);

//change of players-paddles coordinates
always_ff @(posedge clk) begin
	if(rst || won) begin
		P1_paddle_upper_limit <= 275;
		P1_paddle_down_limit <= 324;
		P2_paddle_upper_limit <= 275;
		P2_paddle_down_limit <= 324;
	end
	
	else if(play && move_enable && pxlClk) begin
		//P1
		if(P1_move_up) begin
			P1_paddle_upper_limit <= P1_paddle_upper_limit - 5;
			P1_paddle_down_limit <= P1_paddle_down_limit - 5;
		end
		
		else if(P1_move_down) begin
			P1_paddle_upper_limit <= P1_paddle_upper_limit + 5;
			P1_paddle_down_limit <= P1_paddle_down_limit + 5;
		end
		//P2
		if(P2_move_up) begin
			P2_paddle_upper_limit <= P2_paddle_upper_limit - 5;
			P2_paddle_down_limit <= P2_paddle_down_limit - 5;
		end
		
		else if(P2_move_down) begin
			P2_paddle_upper_limit <= P2_paddle_upper_limit + 5;
			P2_paddle_down_limit <= P2_paddle_down_limit + 5;
		end
	end
end


// score-keeping
	

//frame print
always_ff @(posedge clk) begin
	if (rst || won) begin
	  	red <= min;
	  	blue <= min;
	  	green <= min;
	  	hsync <= 1'b1;		
	  	vsync <= 1'b1;
	  	rows_count <= 0;
	  	cols_count <= 0;
	end
		
	else begin
	  if (pxlClk) begin	  
	    	//horizontal white lines		
	    	if((((rows_count > 149 && rows_count < 165) | (rows_count > 434 && rows_count < 450)) && (cols_count > 199 && cols_count < 600))) begin
	   		red <= max;																																							
	  		blue <= max;
	  		green <= max;
			cols_count <= cols_count + 1;
	    	end
	    	//Left-Player - P1
	    	else if((cols_count > 199 && cols_count < 215) && (rows_count > P1_paddle_upper_limit && rows_count < P1_paddle_down_limit)) begin 
			red <= max;
	  		blue <= max;
	  		green <= max;
			cols_count <= cols_count + 1;  
	    	end
		//Right Player - P2
	    	else if((cols_count > 584 && cols_count < 600) && (rows_count > P2_paddle_upper_limit && rows_count < P2_paddle_down_limit)) begin 
			red <= max;
	  		blue <= max;
	  		green <= max;
			cols_count <= cols_count + 1;  
	    	end
	    	//white square		
	    	else if(((cols_count > sq_left_limit && cols_count < sq_right_limit) && (rows_count > sq_upper_limit && rows_count < sq_down_limit))) begin 
			red <= max;
	  		blue <= max;
	  		green <= max;
			cols_count <= cols_count + 1;
	    	end	
	    	//blackened background	
	    	else begin	
			//hsync
			if(cols_count>=800) begin
				if(cols_count > 856 && cols_count < 976)
					hsync <= 0;
				else
					hsync <= 1;
			end
			//vsync
			if(rows_count>=600) begin
				if(rows_count > 637 && rows_count < 643)
					vsync <= 0;
				else
					vsync <= 1;
			end

			//change line - possibly frame
			if(cols_count == 1040) begin
				cols_count <= 0;
				if(rows_count == 666)
					rows_count <= 0;
				else
					rows_count <= rows_count + 1;
			end
			else 
				cols_count <= cols_count + 1;
			//paint black
			red <= min;
	  		blue <= min;
	  		green <= min;		
	    	end	
    	    	     
	  end
	end
end

endmodule
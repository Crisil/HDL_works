// A 1 bit adder implementation
// Inputs :
// 		in1, in2	-- Single bit inputs to FSM adder 
// Outputs:
//		S, Cout 	-- Sum and Carry out values
module adder_1bit_fsm
(
	input clk,
	input rstn,
	input in1,
	input in2,

	output S,
	output C 
);

// States for Adder Carry
// S0 - Carry NOT present
// S1 - Carry present
// 				(in1, in2/S)
// 00/0 S0		  11/0 --> S1 01/0
// 01/1 S0	<--	00/1     S1 10/0
// 10/1 S0               S1 11/1
localparam S0 = 0;
localparam S1 = 1;

// register store Carry states
reg C_state, C_nxt;
reg S_nxt;

// Update next state
always @(posedge clk) begin
	if (!rstn) begin
		C_state <= S0;
	end else begin
		C_state <= C_nxt;
	end
end

// Obtain next state equation
always @(*) begin
	C_nxt = C_state;
	S_nxt = 1'b0;
	case (C_state) 
		S0 : begin
			S_nxt = in1 ^ in2;
			if (in1 & in2) 
				C_nxt = S1;
		end

		S1 : begin
			S_nxt = ~(in1 ^ in2);
			if (~in1 & ~in2)
				C_nxt = S0;
		end
	endcase
end

// Determine Sum and Carry
// Carry is 1 cycle late compared to Sum
assign C = (C_state == S1) ? 1'b1 : 1'b0;
assign S = S_nxt;

endmodule 

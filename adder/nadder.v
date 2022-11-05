// A N bit adder implementation
// Inputs:
// 		in1, in2	-- Inputs to adder
// 		Cin       -- Carry in 
// Outputs:
// 		Carry, Sum  -- Carry and Sum of adder
module nadder #(parameter DWIDTH = 8)
(
	input [DWIDTH-1:0] in1,
	input [DWIDTH-1:0] in2,
	input Cin,

	output [DWIDTH-1:0] Sum,
	output Carry
);

assign {Carry, Sum} = in1 + in2 + Cin;
endmodule

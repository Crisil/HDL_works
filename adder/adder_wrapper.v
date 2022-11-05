// A verilog wrapper for implementing N bit adder circuits
// Inputs:
// 		in1, in2 -- Two data vectors
// 		ivalid   -- Valid input data in the bus
// Outputs:
// 		Sum      -- Sum value
// 		Carry    -- Carry 
// 		ovalid   -- ouput data is valid
module adder_wrapper #(parameter DWIDTH = 8, parameter TYP = 0, parameter NUM_STAGES = 2)
(
	input clk,
	input rstn,

	input [DWIDTH-1:0] in1,
	input [DWIDTH-1:0] in2,
	input ivalid,

	output [DWIDTH-1:0] Sum,
	output Carry,
	output ovalid,
	output busy
);


generate 
if (TYP == 0) begin : add0
	sequential_adder_top #(.DWIDTH(DWIDTH)) u_adder
	(
		.clk    (clk),
		.rstn   (rstn),
		.in1    (in1),
		.in2    (in2),
		.ivalid (ivalid),
		.Sum    (Sum),
		.Carry  (Carry),
		.ovalid (ovalid),
    .busy   (busy)
	);
end else if (TYP == 1) begin : add1
	parallel_adder_top #(.DWIDTH(DWIDTH)) u_adder
	(
		.clk    (clk),
		.rstn   (rstn),
		.in1    (in1),
		.in2    (in2),
		.ivalid (ivalid),
		.Sum    (Sum),
		.Carry  (Carry),
		.ovalid (ovalid),
    .busy   (busy)
	);
end else if (TYP == 2) begin : add2
	pipeline_adder_top #(.DWIDTH(DWIDTH), .NUM_STAGES(NUM_STAGES)) u_adder
	(
		.clk    (clk),
		.rstn   (rstn),
		.in1		(in1),
		.in2		(in2),
		.ivalid (ivalid),
		.Sum    (Sum),
		.Carry  (Carry),
		.ovalid (ovalid),
		.busy   (busy)
	);
end
endgenerate

endmodule

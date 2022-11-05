// A verilog implementation of N bit parallel adder circuit
// Inputs:
// 		in1, in2 -- Two data vectors
// 		ivalid   -- Valid input data in the bus
// Outputs:
// 		Sum      -- Sum value
// 		Carry    -- Carry 
// 		ovalid   -- ouput data is valid
// 		busy     -- Adder busy 

module parallel_adder_top #(parameter DWIDTH = 8)
(
	input clk,
	input rstn,

	input [DWIDTH-1:0] in1,
	input [DWIDTH-1:0] in2,
	input ivalid, 

	output [DWIDTH-1:0] Sum,
	output Carry,
	output reg ovalid,
	output reg busy
);

reg [DWIDTH-1:0] f_in1;
reg [DWIDTH-1:0] f_in2;

// flop the incoming data
always @(posedge clk) begin
	if (!rstn) begin
		f_in1 <= {DWIDTH{1'b0}};
		f_in2 <= {DWIDTH{1'b0}};
	end else if (ivalid) begin
		f_in1 <= in1;
		f_in2 <= in2;
	end
end

// Calculate adder results
nadder #(.DWIDTH(DWIDTH)) u_nadder
(
	.in1   (f_in1),
	.in2   (f_in2),
	.Cin   (1'b0),
	.Sum   (Sum),
	.Carry (Carry)
);

// assert output valid signal
always @(posedge clk) begin
	if (!rstn)
		ovalid <= 1'b0;
	else
		ovalid <= ivalid;
end

// assert adder busy signal, adder is 
// busy from ivalid to ovalid
always @(posedge clk) begin
	if (!rstn)
		busy <= 1'b0;
	else if (ivalid)
		busy <= 1'b1;
	else if (ovalid)
		busy <= 1'b0;
end

endmodule

// A verilog implementation of N bit pipeline adder circuit
// Inputs:
// 		in1, in2 -- Two data vectors
// 		ivalid   -- Valid input data in the bus
// Outputs:
// 		Sum      -- Sum value
// 		Carry    -- Carry 
// 		ovalid   -- ouput data is valid
// 		busy     -- Adder busy 

module pipeline_adder_top #(parameter DWIDTH = 8, parameter NUM_STAGES = 2)
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

// minimum adder width required in each stage
localparam MIN_DWDITH = DWIDTH/NUM_STAGES;

// internal wire used before shift operation & store after addition
wire [DWIDTH-1:0] in1_pre;
wire [DWIDTH-1:0] in2_pre;
wire [DWIDTH-1:0] S_int;

// Carry input for each stages
wire [NUM_STAGES:0] C_pre;
wire [NUM_STAGES:0] C_int;
wire  C_out;

// Carry input for 1st adder stage is 0
assign C_pre[0] = 1'b0;

genvar stage;
generate
	for (stage = 0; stage < NUM_STAGES; stage=stage+1) begin
		// implement shifter before addition for required stages
		data_shifter #(.LATENCY(stage), .IWIDTH(MIN_DWDITH)) u_shifter1_pre
		(
			.clk   (clk),
			.rstn  (rstn),
			.idata (in1[stage*MIN_DWDITH +: MIN_DWDITH]),
			.odata (in1_pre[stage*MIN_DWDITH +: MIN_DWDITH])
		);

		data_shifter #(.LATENCY(stage), .IWIDTH(MIN_DWDITH)) u_shifter2_pre
		(
			.clk   (clk),
			.rstn  (rstn),
			.idata (in2[stage*MIN_DWDITH +: MIN_DWDITH]),
			.odata (in2_pre[stage*MIN_DWDITH +: MIN_DWDITH])
		);
		
		// implement n-bit adder & add each stage 
		// take carry from the last stage
		nadder #(.DWIDTH(MIN_DWDITH)) u_nadder
		(
			.in1   (in1_pre[stage*MIN_DWDITH +: MIN_DWDITH]),
			.in2   (in2_pre[stage*MIN_DWDITH +: MIN_DWDITH]),
			.Cin   (C_pre[stage]),
			.Sum   (S_int[stage*MIN_DWDITH +: MIN_DWDITH]),
			.Carry (C_int[stage])
		);

	  // delay carry by 1 cycle as its an input for next cycle
		data_shifter #(.LATENCY(1), .IWIDTH(1'b1)) u_shifter_carry
		(
			.clk   (clk),
			.rstn  (rstn),
			.idata (C_int[stage]),
			.odata (C_pre[stage+1])
		);
    
		// implement shift operation post addition
		data_shifter #(.LATENCY(NUM_STAGES - stage), .IWIDTH(MIN_DWDITH)) u_shifter_sum
		(
			.clk   (clk),
			.rstn  (rstn),
			.idata (S_int[stage*MIN_DWDITH +: MIN_DWDITH]),
			.odata (Sum[stage*MIN_DWDITH +: MIN_DWDITH])
		);

		// generate valid signal, each addition takes two clock cycle
		data_shifter #(.LATENCY(NUM_STAGES), .IWIDTH(1'b1)) u_valid_shift
		(
			.clk   (clk),
			.rstn  (rstn),
			.idata (ivalid),
			.odata (ovalid)
		);
	end
	// Carry from last stage
	assign Carry = C_pre[NUM_STAGES];
endgenerate

// adder is always available for operation
// it can take a new input every clock cycle
assign busy = 1'b0;
endmodule

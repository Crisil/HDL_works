// A verilog implementation of N bit sequentail adder circuit
// using 1 bit adder and shift register
// Inputs:
// 		in1, in2 -- Two data vectors
// 		ivalid   -- Valid input data in the bus
// Outputs:
// 		Sum      -- Sum value
// 		Carry    -- Carry 
// 		ovalid   -- ouput data is valid
// 		busy     -- Adder busy 

module sequential_adder_top #(parameter DWIDTH = 8)
(
	input clk,
	input rstn,

	input [DWIDTH-1:0] in1,
	input [DWIDTH-1:0] in2,
	input ivalid,

	output [DWIDTH-1:0] Sum,
	output Carry,
	output ovalid,
	output reg busy
);

wire [DWIDTH-1:0] w_in1_sft; // shifted inputs
wire [DWIDTH-1:0] w_in2_sft;
wire w_shift;

wire w_sum, w_carry;

// width of counter
localparam CWIDTH = $clog2(DWIDTH);
reg [CWIDTH-1:0] counter;

// output validity signals
reg ovalid_p1;
reg ovalid_p2;
reg ovalid_p3;

// shifter for input 1
shiftl2r #(.DWIDTH(DWIDTH)) u_in1_shft
(
	.clk      (clk),
	.rstn     (rstn),
	.idata    (in1),
	.load     (ivalid),
	.shift2r  (w_shift),
	.msb_bit  (1'b0),
	.odata    (w_in1_sft)
);

// shifter for input 2
shiftl2r #(.DWIDTH(DWIDTH)) u_in2_shft
(
	.clk      (clk),
	.rstn     (rstn),
	.idata    (in2),
	.load     (ivalid),
	.shift2r  (w_shift),
	.msb_bit  (1'b0),
	.odata    (w_in2_sft)
);

// single bit adder whenever input available calc sum
// carry is 1 cycle later compared to sum
adder_1bit_fsm u_adder
(
	.clk (clk),
	.rstn(rstn),
	.in1 (w_in1_sft[0]),
	.in2 (w_in2_sft[0]),
	.S   (w_sum),
	.C   (w_carry)
);

// shift in sum data from adder
shiftl2r #(.DWIDTH(DWIDTH)) u_addr_shft
(
	.clk      (clk),
	.rstn     (rstn),
	.idata    ({DWIDTH{1'b0}}),
	.load     (ivalid),
	.shift2r  (!ovalid_p1),
	.msb_bit  (w_sum),
	.odata    (Sum)
);

// Counter to determine completion of add operations
always @(posedge clk) begin
	if (!rstn) 
		counter <= DWIDTH - 1;
	else if (ivalid)
		counter <= DWIDTH - 1;
	else
		counter <= counter - 1'b1;
end

// Validity ouput sum determined
// Counter reaches 0 --> ouput data is valid
// Stop shift in of sum data based on ovalid_p1
always @(posedge clk) begin
	if (!rstn)
		ovalid_p1 <= 1'b0;
	else if (ivalid)
		ovalid_p1 <= 1'b0;
	else if (!counter)
		ovalid_p1 <= 1'b1;
end

// Align Sum with Carry by delaying 1 cycle
// Create a pulse for valid signal
always @(posedge clk) begin
	ovalid_p2 <= ovalid_p1;
	ovalid_p3 <= ovalid_p2;
end
assign ovalid = ovalid_p2 & ~ovalid_p3;

// Calc shift and assign carry out
assign w_shift  = (counter == 0) ? 1'b0 : 1'b1;
assign Carry = w_carry;

// Busy signal to determine adder status
always @(posedge clk) begin
	if (!rstn)
		busy <= 1'b0;
	else if (ivalid)
		busy <= 1'b1;
	else if (ovalid)
		busy <= 1'b0;
end

endmodule

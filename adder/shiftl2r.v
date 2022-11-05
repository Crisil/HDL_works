// A verilog module to perform left to right shift
// Inputs: 
//   load     - latch data from input
//   shift2r  - enable shift operation
//   idata    - input data 
//   msb_bit  - MSB bit for R2L operation
// Outputs:
//   odata    - Left2Right shifted data

module shiftl2r #(parameter DWIDTH=8)
(
	input clk,
	input rstn,

	input [DWIDTH-1:0] idata,
	input load,
	input shift2r,
	input msb_bit,
	output reg [DWIDTH-1:0] odata
);

integer i;

// Latch input data as per the value of load signal or 1 bit signal 
// added to MSB during shift operation
// Perform L2R shift operation as per the state of shift2r
always @(posedge clk) begin
	if (!rstn)
		odata <= {DWIDTH{1'b0}};
	else if (load)
		odata <= idata;
	else if (shift2r) begin
		for (i = DWIDTH-1; i > 0; i = i-1) begin
			odata[i-1] <= odata[i];
		end
		odata[DWIDTH-1] <= msb_bit;
	end
end

endmodule

// An FIR filter TAP implementation
// Inputs:
//	clk, rstn, 
//	i_data - Input data sample
//	coeff  - filter coefficient for that tap
//	i_accdata - Input accumulated data
// Outputs:
//	o_data - Delayed data to next stage
//	o_accdata - Output accumulated data

module fir_stage #(parameter DWIDTH = 16)
(
	input clk, 
	input rstn, 

	input signed [DWIDTH-1:0] i_data,
	input signed [DWIDTH-1:0] coeff,
	input signed [(2*DWIDTH)-1:0] i_accdata,

	output signed [DWIDTH-1:0]     o_data,
	output signed [(2*DWIDTH)-1:0] o_accdata
);
 
reg signed [DWIDTH-1:0]     xin_d;		// shifted input data
reg signed [(2*DWIDTH)-1:0] a_data;   // product of input & coeff

// Calculate delayed and accumelated product data
always @(posedge clk) begin
	if (!rstn) begin
		xin_d  <= {DWIDTH{1'b0}};
		a_data <= {2*DWIDTH{1'b0}};
	end else begin
		xin_d  <= i_data;
		a_data <= i_accdata + (i_data * coeff);
	end
end

assign o_accdata = a_data;
assign o_data    = xin_d;

endmodule

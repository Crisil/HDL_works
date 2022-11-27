`timescale 1ns / 1ps
// A FIR filter implementation using given coefficients
// 15 tap filter is implemented

module fir #(parameter DWIDTH = 16)
(
  input clk,
  input rstn,

	input signed [DWIDTH-1:0] i_data,
	input i_valid, 
	output o_ready,

	output signed [(2*DWIDTH)-1:0] o_data,
	output o_valid,
	input  i_ready
 );
localparam NUM_TAPS = 15;
wire signed [DWIDTH-1:0] taps[0:NUM_TAPS-1];

wire signed [DWIDTH-1:0] stage_data[0:NUM_TAPS];
wire signed [(2*DWIDTH)-1:0] stage_accdata[0:NUM_TAPS];

assign stage_data[0]    = i_data;
assign stage_accdata[0] = {2*DWIDTH{1'b0}};

/* Taps for LPF running @ 1MSps */
assign taps[0]  = 16'hFC9C;  // twos(-0.0265 * 32768) = 0xFC9C
assign taps[1]  = 16'h0000;  // 0
assign taps[2]  = 16'h05A5;  // 0.0441 * 32768 = 1445.0688 = 1445 = 0x05A5
assign taps[3]  = 16'h0000;  // 0
assign taps[4]  = 16'hF40C;  // twos(-0.0934 * 32768) = 0xF40C
assign taps[5]  = 16'h0000;  // 0
assign taps[6]  = 16'h282D;  // 0.3139 * 32768 = 10285.8752 = 10285 = 0x282D
assign taps[7]  = 16'h4000;  // 0.5000 * 32768 = 16384 = 0x4000
assign taps[8]  = 16'h282D;  // 0.3139 * 32768 = 10285.8752 = 10285 = 0x282D
assign taps[9]  = 16'h0000;  // 0
assign taps[10] = 16'hF40C;  // twos(-0.0934 * 32768) = 0xF40C
assign taps[11] = 16'h0000;  // 0
assign taps[12] = 16'h05A5;  // 0.0441 * 32768 = 1445.0688 = 1445 = 0x05A5
assign taps[13] = 16'h0000;  // 0
assign taps[14] = 16'hFC9C;  // twos(-0.0265 * 32768) = 0xFC9C

genvar i;
generate 
	for (i = 0; i < NUM_TAPS; i = i+1) begin  : stage
		fir_stage #(.DWIDTH(DWIDTH)) u_fir_stage
		(
			.clk       (clk),
			.rstn      (rstn),
			.i_data    (stage_data[i]),
			.coeff     (taps[i]),
			.i_accdata (stage_accdata[i]),
			.o_data    (stage_data[i+1]),
			.o_accdata (stage_accdata[i+1])
		);
	end
endgenerate

assign o_data = stage_accdata[NUM_TAPS];
endmodule

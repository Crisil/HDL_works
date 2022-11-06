// A module to pipeline data based on number of LATENCY parameters
// LATENCY - Number of pipeline stages in the path
// Inputs:
// 	clk, rstn
// 	idata - Input data
// Outputs:
// 	odata - Output data

module data_shifter #(parameter LATENCY = 1, parameter IWIDTH = 8)
(
	input clk,
	input rstn,

	input  [IWIDTH-1:0] idata,
	output [IWIDTH-1:0] odata
);


genvar m;
generate 
	if (LATENCY == 0) begin
		assign odata = idata;
	end else begin
		// data to hold input data and perform shifting
    reg [LATENCY*IWIDTH-1: 0] shift_register;
	  for (m = LATENCY; m > 0; m=m-1) begin
	  	always @(posedge clk) begin
	  		if (!rstn)
	  			shift_register[(m*IWIDTH - 1) -: IWIDTH] <= 0;
	  		else begin
					// store input data 
	  			if (m == LATENCY)
	  				shift_register[(m*IWIDTH - 1) -: IWIDTH] <= idata[IWIDTH-1:0];
					// shift data based on width
	  			else
	  				shift_register[(m*IWIDTH - 1) -: IWIDTH] <= shift_register[((m+1)*IWIDTH - 1) -: IWIDTH];
	  		end
	  	end
	  end
		// lsb data is the shifted ouput based on latency
    assign odata = shift_register[IWIDTH-1:0];
  end
endgenerate
endmodule

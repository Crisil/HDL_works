// A verilog implementation of pipelined skid buffer
// Inputs:
// 		clk, rstn
// 		i_data  - Input data
// 		i_valid - Input data valid
// 		o_ready - Module ready to access data
// Outputs:
// 		o_data  - Output data
// 		o_valid - Output data validy
// 		i_ready - Downstream module ready to accespt data

module pipe #(parameter DWIDTH = 8)
(
	input clk,
	input rstn,

	input [DWIDTH-1:0] i_data,
	input  i_valid,
	output reg o_ready,

	output reg [DWIDTH-1:0] o_data,
	output reg o_valid,
	input  i_ready
);
// State 
localparam S0 = 0;
localparam S1 = 1;

reg nxt_state;
reg state;

// skid buffer control signal
reg r_skid_valid;

// skid buffer 
reg [DWIDTH-1:0] r_idata;

always @(posedge clk) begin
	if (!rstn) begin
		state <= S0;
	end else begin
		state <= nxt_state;
	end
end

// nxt state calculation
always @(*) begin
	nxt_state  = state;
	r_skid_valid = 1'b0;
	case (state)
		S0 : begin
			// downstream module ready to accept data
			// pass through data else store in skid buffer 
			if(i_valid) begin
			  r_skid_valid = 1'b0;
			  if (!i_ready) begin
			  	nxt_state  = S1;
			  end
		  end
		end
    // send data from skid buffer 
		S1 : begin
			if (i_ready) begin
				nxt_state  = S0;
			end
		  r_skid_valid = 1'b1;
		end
	endcase
end

// store data to skid buffer 
always @(posedge clk) begin
	if (i_valid & !r_skid_valid) begin
		r_idata <= i_data;
	end
end

// generate ouput signals based of skid buffer validity
always @(posedge clk) begin
	if (!rstn) begin
		o_valid <= 1'b0;
	end else begin
		// downstream module is ready to receive data
		// 	based on the availability skid buffer push data eiter from 
		// 	skid buffer of input else in valid 
	  if (i_ready) begin
	    if (r_skid_valid) begin
	    	o_data  <= r_idata;
	    	o_valid <= 1'b1;
	    end else if (i_valid) begin
	    	o_data  <= i_data;
	    	o_valid <= 1'b1;
			end else begin
				o_valid <= 1'b0;
			end
	  end else begin
	  	o_valid <= 1'b0;
	  end
	end
end

// generate modules ready status to upstream modules
// As long as skid buffer is empty module can receive new data
always @(posedge clk) begin
	if (!rstn) begin
		o_ready <= 1'b0;
	end else begin
		if (r_skid_valid)
			o_ready <= 1'b0;
		else
			o_ready <= 1'b1;
	end
end

endmodule

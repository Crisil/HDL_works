/*
 * A synchronous fifo design
 */
module fifo #(parameter AWIDTH = 4, parameter DWIDTH = 8)
(
	input clk,
	input rstn,

	input [DWIDTH-1:0] idata,
	input wren,

	output [DWIDTH-1:0] odata,
	input  ren,

	output full,
	output empty
);

localparam DEPTH = (1 << AWIDTH);

reg [DWIDTH-1:0] fifo [0:DEPTH-1];
reg [AWIDTH-1:0] f_wr_ptr;
reg [AWIDTH-1:0] f_rd_ptr;
reg [AWIDTH:0]   fifo_occ; 

assign full  = (fifo_occ >= DEPTH-1);
assign empty = (fifo_occ == 0);

// fifo occupancy calculations
always @(posedge clk or negedge rstn) begin
	if (!rstn)
		fifo_occ <= 0;
	else begin
		case ({ren, wren})
			2'b00 : fifo_occ <= fifo_occ;
			2'b01 : fifo_occ <= fifo_occ + 1'b1;
			2'b10 : fifo_occ <= fifo_occ - 1'b1;
			2'b11 : fifo_occ <= fifo_occ;
		endcase
	end
end


// write pointer increment
always @(posedge clk or negedge rstn) begin
	if (!rstn) 
		f_wr_ptr <= 0;
	else
		f_wr_ptr <= f_wr_ptr + wren;
end

// read pointer increment
always @(posedge clk or negedge rstn) begin
	if (!rstn)
		f_rd_ptr <= 0;
	else
		f_rd_ptr <= f_rd_ptr + ren;
end

// FIFO read and write logic
always @(posedge clk) begin
	if (wren)
		fifo[f_wr_ptr] <= idata;
end
assign odata = fifo[f_rd_ptr];

endmodule

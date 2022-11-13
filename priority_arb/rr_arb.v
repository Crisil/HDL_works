// A module to implement round robit arbitrator
// Output is avaliable in the next cycle
// Inputs:
// 		clk, rstn
// 		i_grant -- Input vectors for arbitration
// 		i_valid -- Validty of input vectors
// Outputs:
// 		o_grant -- Output grant vectors, will set only 1 bit
// 		o_valid -- Validity of o_grant

module rr_arb #(parameter NUM_INPUTS = 8) 
(
	input clk,
	input rstn,
	input [NUM_INPUTS-1:0] i_grant,
	input i_valid,

	output [NUM_INPUTS-1:0] o_grant,
	output reg o_valid
);

localparam M = $clog2(NUM_INPUTS);	// store width of src number

reg [M-1:0] last_sel_src; 					// last selected src
reg [M-1:0] selected_src;					

wire [M-1:0] curr_sel_src;			 	 // Current selected src
reg  [M-1:0] curr_sel_src_d;			 // Current selected src

reg [NUM_INPUTS-1:0] rotate_bmap;	 // input grant after rotation

// Determine rotate bitmap based on inputs and last selected src
// Based on last selected src rotate input vectors
always @(*) begin
	rotate_bmap = {NUM_INPUTS{1'b0}};
	case (last_sel_src) 
		0 : rotate_bmap = {i_grant[0:0], i_grant[7:1]}; 
		1 : rotate_bmap = {i_grant[1:0], i_grant[7:2]};
		2 : rotate_bmap = {i_grant[2:0], i_grant[7:3]};
		3 : rotate_bmap = {i_grant[3:0], i_grant[7:4]};
		4 : rotate_bmap = {i_grant[4:0], i_grant[7:5]};
		5 : rotate_bmap = {i_grant[5:0], i_grant[7:6]};
		6 : rotate_bmap = {i_grant[6:0], i_grant[7:7]};
		7 : rotate_bmap = {i_grant[7:0]};
	endcase
end

// Priority encoder to determine first requested src after RR
always @(*) begin
	selected_src = 0;
	if (rotate_bmap[0])
		selected_src = 0;
	else if (rotate_bmap[1])
		selected_src = 1;
	else if (rotate_bmap[2])
		selected_src = 2;
	else if (rotate_bmap[3])
		selected_src = 3;
	else if (rotate_bmap[4])
		selected_src = 4;
	else if (rotate_bmap[5])
		selected_src = 5;
	else if (rotate_bmap[6])
		selected_src = 6;
	else if (rotate_bmap[7])
		selected_src = 7;
end

// determine src which wins arbitration 
// Add last selected src since there is a rotation
assign curr_sel_src = last_sel_src + selected_src + 1'b1;

// Flop src
always @(posedge clk) begin
	if (!rstn) begin
		curr_sel_src_d <= 0;
	end else begin
		curr_sel_src_d <= curr_sel_src;
	end
end

// store last selected src
always @(posedge clk) begin
	if (!rstn) begin
		last_sel_src <= 0;
	end else begin
		last_sel_src <= curr_sel_src;
	end
end

// generate gand signal based on flopped version of current selected signal
assign o_grant = 1'b1 << curr_sel_src_d;

// generate valid signal, flopped version of input valid 
always @(posedge clk) begin
	if (!rstn) o_valid <= 1'b0;
	else begin
		o_valid <= i_valid;
	end
end

endmodule

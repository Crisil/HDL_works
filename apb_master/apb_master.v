module apb_master
(
	input clk,
	input rst_n,
	input [1:0] cmd_i,

	output psel_o,
	output penable_o,
	output [31:0] paddr_o,
	output pwrite_o,
	output [31:0] pwdata_o,
	input  pready_i,
	input  [31:0] prdata_i
);

  localparam ST_IDLE   = 2'b00;
	localparam ST_SETUP  = 2'b01;
	localparam ST_ACCESS = 2'b10;

	reg [1:0] state;
	reg [1:0] nxt_state;
	reg [31:0] rdata;

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			state <= 1'b0;
		else
			state <= nxt_state;
	end

	always @* begin
		case (state)
			ST_IDLE  : if (|cmd_i) nxt_state = ST_SETUP; else nxt_state = ST_IDLE;
			ST_SETUP : nxt_state = ST_ACCESS;
		  ST_ACCESS: if (pready_i) nxt_state = ST_IDLE;
			default  : nxt_state = state; 
		endcase
	end

	assign psel_o   = (state == ST_ACCESS) | (state == ST_SETUP);
	assign pwrite_o = cmd_i[1];
	assign paddr_o  = 32'hDEADBEEF;
	assign pwdata_o = rdata + 1'b1;
	assign penable_o = (state == ST_ACCESS);

	always @(posedge clk or negedge rst_n) begin
		if (!rst_n)
			rdata <= 32'b0;
		else if (penable_o && pready_i)
			rdata <= prdata_i;
	end
endmodule

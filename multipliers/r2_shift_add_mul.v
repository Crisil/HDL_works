// A module to implement radix 2 shit add multiplication
// z[i+1] = (z[i] + (x * 2^n) * y)/2
// where n is the number of bits
// Load value to X regsiter shift data by n bits
// perform AND operation with y and add to previous 
// operation and shift by 1 to get new result, repeat N-1 steps

module r2_shift_add_mul #(parameter DWIDTH = 8, 
													parameter OWIDTH = 2*DWIDTH)
(
	input clk,
	input rstn, 

	input  [DWIDTH-1:0] Xin,
	input  [DWIDTH-1:0] Yin,
	input  i_valid,
	output [OWIDTH-1:0] Zout,
	output reg o_valid
);
localparam CNTWIDTH = $clog2(DWIDTH) + 1;

reg [DWIDTH-1:0] f_X;
reg [DWIDTH-1:0] f_Y;
reg [OWIDTH-1:0] f_Z;
reg [CNTWIDTH-1:0] counter;

reg ldX;
reg ldY;
reg ldZ;
reg ClrZ;
reg ClrC;
reg SftY;
wire [DWIDTH-1:0] XandY;
wire [DWIDTH-1:0] u_Z;
wire [DWIDTH:0] w_Z;

localparam [1:0] IDLE   = 2'b00;
localparam [1:0] START  = 2'b01;
localparam [1:0] ACTIVE = 2'b10;
localparam [1:0] DONE   = 2'b11;

reg [1:0] state;
reg [1:0] nxt_state;
reg [1:0] X;

// next state logic
always @(posedge clk) begin
	if (!rstn) begin
		state <= IDLE;
	end else begin
		state <= nxt_state;
	end
end

always @(*) begin
	nxt_state = state;
	ldX  = 1'b0;
	ldY  = 1'b0;
	ldZ  = 1'b0; 
	ClrZ = 1'b0;
	SftY = 1'b0;
	ClrC = 1'b1;
	o_valid = 1'b0;
	case(state)
		IDLE : begin
			if (i_valid) begin
				nxt_state = START;
			end
		end
	  START: begin
			ldX = 1'b1;
			ldY = 1'b1;
			ClrC = 1'b0;
			ClrZ = 1'b1;
			nxt_state = ACTIVE;
		end
		ACTIVE: begin
			ClrC = 1'b0;
			SftY = 1'b1;
			ldZ = 1'b1;
			if (counter == DWIDTH) begin
				nxt_state = DONE;
			end
		end
		DONE: begin
			o_valid = 1'b1;
			nxt_state = IDLE;
		end
	endcase
end

always @(posedge clk) begin
	if (!rstn) begin
		f_X <= {DWIDTH{1'b0}};
	end else begin
		if (ldX) begin
			f_X <= Xin;
		end
	end
end

always @(posedge clk) begin
	if (!rstn) begin
		f_Y <= {DWIDTH{1'b0}};
	end else begin
		if (ldY) begin
			f_Y <= Yin;
		end else if (SftY) begin
			f_Y <= {1'b0, f_Y[DWIDTH-1:1]};
		end
	end
end

assign XandY = f_X & {DWIDTH{f_Y[0]}};
assign u_Z   = f_Z[OWIDTH-1:DWIDTH];
assign w_Z   = u_Z + XandY[DWIDTH-1:0];

always @(posedge clk) begin
	if (!rstn) begin
		f_Z <= {OWIDTH{1'b0}};
	end else begin
		if (ClrZ) begin
			f_Z <= {OWIDTH{1'b0}};
		end else if (ldZ) begin
			f_Z <= {w_Z, f_Z[DWIDTH-1:1]};
		end
	end
end

always @(posedge clk) begin
	if (!rstn || ClrC) begin
		counter <= 0;
	end else begin
		counter <= counter + 1'b1;
	end
end

assign Zout = f_Z[OWIDTH-1:0];
endmodule

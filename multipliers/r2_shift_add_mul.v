// A module to implement radix 2 shit add multiplication
// z[i+1] = (z[i] + (x * 2^n) * y)/2
// where n is the number of bits
// Load value to X regsiter shift data by n bits
// perform AND operation with y and add to previous 
// operation and shift by 1 to get new result, repeat N-1 steps
// Eg: 2 x 3 = 6
// X = 2, Y = 3, yi = bits of Y
// X = 0010
// Y = 0011

// Z0             = 0000 0000
// (X * 2^3) * y0 = 0010 0000
// Z0'            = 0010 0000 (op1 - Add Z0 + (X * 2^3) * y0)
// Z1             = 0001 0000 (op2 - Shift Z0')
// (X * 2^3) * y1 = 0010 0000 
// Z1'            = 0011 0000 op1
// Z1             = 0001 1000 op2
// (X * 2^3) * y2 = 0000 0000
// Z2'            = 0001 1000 op1
// Z2             = 0000 1100 op2
// X * 2^3) * y3  = 0000 0000 
// Z3'            = 0000 1100 op1
// Z3             = 0000 0110 op2 --> 6 (ans)


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
// count the number of clocks
localparam CNTWIDTH = $clog2(DWIDTH) + 1;
reg [CNTWIDTH-1:0] clk_counter;

// store flopped inputs
reg [DWIDTH-1:0] f_X;
reg [DWIDTH-1:0] f_Y;
reg [OWIDTH-1:0] f_Z;

// control signals from FSM
reg ldX;	// load Xin to f_X
reg ldY;	// load Yin to f_Z
reg ldZ;	// load f_Z
reg ClrZ; // Clear f_Z
reg ClrC;	// Clear clk_counter
reg SftY; // Shift Y

wire [DWIDTH-1:0] XandY;  // store X & yi
wire [DWIDTH-1:0] msb_fZ; // store MSB part of f_Z

// store the result of sum
// Extra bit to accomodate carry
wire [DWIDTH:0] msb_sumZ; 
// state variables													
localparam [1:0] IDLE   = 2'b00;
localparam [1:0] START  = 2'b01;
localparam [1:0] ACTIVE = 2'b10;
localparam [1:0] DONE   = 2'b11;

reg [1:0] state;
reg [1:0] nxt_state;

always @(posedge clk) begin
	if (!rstn) begin
		state <= IDLE;
	end else begin
		state <= nxt_state;
	end
end

// next state logic
// FSM IDLE -> START -> ACTIVE (DWIDTH times) -> DONE -> IDLE
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
			// valid input received, move to start
			if (i_valid) begin
				nxt_state = START;
			end
		end
	  START: begin
			// load input data to register
			ldX  = 1'b1;
			ldY  = 1'b1;
			ClrC = 1'b0;
			ClrZ = 1'b1;
			nxt_state = ACTIVE;
		end
		ACTIVE: begin
			// Clear counter, starts to shift data out from Y
			// for AND operations and store result to f_Z
			ClrC = 1'b0;
			SftY = 1'b1;
			ldZ  = 1'b1;
			// All bits completed
			if (clk_counter == DWIDTH) begin
				nxt_state = DONE;
			end
		end
		DONE: begin
			// completed
			o_valid = 1'b1;
			nxt_state = IDLE;
		end
	endcase
end

// load Xin data to register
always @(posedge clk) begin
	if (!rstn) begin
		f_X <= {DWIDTH{1'b0}};
	end else begin
		if (ldX) begin
			f_X <= Xin;
		end
	end
end

// load Yin data to register
// Shit out data from Y
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

// bitwise AND of X and shifted out Y elements
assign XandY   = f_X & {DWIDTH{f_Y[0]}};

// calc sum of msb bits as lsb bits are 0 
// they are zero because of shifting
assign msb_fZ   = f_Z[OWIDTH-1:DWIDTH];
assign msb_sumZ = msb_fZ + XandY[DWIDTH-1:0];

// clear and update f_Z with new sum values
// f_Z is shifter each clock
always @(posedge clk) begin
	if (!rstn) begin
		f_Z <= {OWIDTH{1'b0}};
	end else begin
		if (ClrZ) begin
			f_Z <= {OWIDTH{1'b0}};
		end else if (ldZ) begin
			f_Z <= {msb_sumZ, f_Z[DWIDTH-1:1]};
		end
	end
end

// clear counter and increment it
always @(posedge clk) begin
	if (!rstn || ClrC) begin
		clk_counter <= 0;
	end else begin
		clk_counter <= clk_counter + 1'b1;
	end
end

// ouput data, carry part ommitted
assign Zout = f_Z[OWIDTH-1:0];
endmodule

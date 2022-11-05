module uart_tx #(parameter NBITS = 8)
(
	input clk,
	input rstn,

	output tx,
	input  tx_clk,

	input  [NBITS-1:0] itx_data,
	input  start_tx,
	output reg tx_done
);
// FSM states
localparam [1:0] IDLE  = 2'b00;
localparam [1:0] START = 2'b01;
localparam [1:0] DATA  = 2'b10;
localparam [1:0] STOP  = 2'b11;

// This is required because rx clk is used for tx also
// Every 16 rx ticks sends out data
localparam INTERVAL_BTW_BITS = 15;

reg [1:0] state;
reg [1:0] nxt_state;

reg [3:0] tx_clk_cntr; // counter to count number of ticks
reg [3:0] tx_clk_cntr_nxt;
reg tx_nxt;
reg tx_data; // tx_data is sent to tx line
reg tx_done_nxt;

reg [NBITS-1:0] data_reg;
reg [NBITS-1:0] data_nxt;
reg [NBITS-1:0] data_cnt;
reg [NBITS-1:0] data_cnt_nxt;

// state assignments
always @(posedge clk or negedge rstn) begin
	if (!rstn) 
		state <= IDLE;
	else
		state <= nxt_state;
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		tx_data     <= 1;
		tx_clk_cntr <= 0;
		data_reg    <= 0;
		data_cnt    <= 0;
		tx_done     <= 1;
	end else begin
		tx_data     <= tx_nxt;
		tx_clk_cntr <= tx_clk_cntr_nxt;
		data_reg    <= data_nxt;
		data_cnt    <= data_cnt_nxt;
		tx_done     <= tx_done_nxt;
	end
end

// next state logic
always @* begin
	nxt_state       = state;
	tx_nxt          = tx_data;
	tx_clk_cntr_nxt = tx_clk_cntr;
	data_nxt        = data_reg;
	data_cnt_nxt    = data_cnt;
	tx_done_nxt     = tx_done;
	case (state)
		// IDLE state, tx line asserted high, wait for start of tx
		// tx busy if start of tx
		IDLE  : begin
			tx_nxt = 1'b1;
			if (start_tx) begin 
				nxt_state = START;
			  data_nxt  = itx_data;
				tx_done_nxt = 1'b0;
			end
		end
    
		// start bit is sent to tx
		// data remains in line for 16 ticks as tx uses same rx ticks
		START : begin
			if (tx_clk) begin
				tx_nxt = 1'b0;
				if (tx_clk_cntr == INTERVAL_BTW_BITS) begin
					tx_clk_cntr_nxt = 0;
					nxt_state       = DATA;
				end else begin
					tx_clk_cntr_nxt = tx_clk_cntr + 1'b1;
				end
			end
		end

		// data tranmission to tx lsb --> msb
		DATA  : begin
			if (tx_clk) begin
			  tx_nxt = data_reg[0];
				if (tx_clk_cntr == INTERVAL_BTW_BITS) begin
					data_cnt_nxt = 0;
					tx_clk_cntr_nxt = 0;
					data_nxt = data_reg >> 1;
					if (data_cnt == (NBITS - 1)) begin
						nxt_state = STOP;
					end else begin
						data_cnt_nxt = data_cnt + 1'b1;
					end
				end else 
					tx_clk_cntr_nxt = tx_clk_cntr + 1'b1;
			end
		end
    
		// stop bit transmission to tx
		// tx line asserted high
		STOP  : begin
			if (tx_clk) begin
			  tx_nxt = 1'b1;
				if (tx_clk_cntr == INTERVAL_BTW_BITS) begin
					tx_clk_cntr_nxt = 0;
					nxt_state = IDLE;
					tx_done_nxt = 1'b1;
				end else begin
					tx_clk_cntr_nxt = tx_clk_cntr + 1'b1;
				end
			end
		end

	endcase 
end

// data to tx 
assign tx = tx_data;
endmodule

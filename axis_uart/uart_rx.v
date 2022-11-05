module uart_rx #(parameter NBITS = 8)
(
	input clk,
	input rstn,

	input rx,
	input rx_clk,
  
	input start_rx,
	output [NBITS-1:0] rx_data,
	output reg rx_done
);

// FSM states
localparam [1:0] IDLE  = 2'b00;
localparam [1:0] START = 2'b01;
localparam [1:0] DATA  = 2'b10;
localparam [1:0] STOP  = 2'b11;

// location of start and data bit samples
localparam START_BIT				 = 7;
localparam INTERVAL_BTW_BITS = 15;

reg [1:0] state;
reg [1:0] nxt_state;

reg [3:0] rx_clk_cntr;
reg [3:0] rx_clk_cntr_nxt;
reg [NBITS-1:0] data_cnt_nxt;
reg [NBITS-1:0] data_cnt;
reg [NBITS-1:0] data_nxt;
reg [NBITS-1:0] data_reg;
reg rx_done_nxt;

always @(posedge clk or negedge rstn) begin
	if (!rstn)
		state <= IDLE;
	else
		state <= nxt_state;
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		rx_clk_cntr <= 0;
		data_cnt    <= 0;
		data_reg    <= 0;
		rx_done     <= 0;
	end else begin
		rx_clk_cntr <= rx_clk_cntr_nxt;
		data_cnt    <= data_cnt_nxt;
		data_reg    <= data_nxt;
		rx_done     <= rx_done_nxt;
	end
end

always @* begin
	nxt_state       = state;
  rx_clk_cntr_nxt = rx_clk_cntr;
	data_cnt_nxt    = data_cnt;
  data_nxt        = data_reg;
	rx_done_nxt     = rx_done;
	case (state)
		IDLE : begin
			if (rx == 1'b0 && start_rx) nxt_state = START;
			rx_done_nxt = 1'b0;
		end

		START : begin
			if (rx_clk) begin
				if (rx_clk_cntr == START_BIT) begin
					rx_clk_cntr_nxt = 0;
					nxt_state = DATA;
				end else begin
					rx_clk_cntr_nxt = rx_clk_cntr + 1'b1;
				end
			end
		end

		DATA : begin
			if (rx_clk) begin
				if (rx_clk_cntr == INTERVAL_BTW_BITS) begin
					rx_clk_cntr_nxt = 0;
					data_cnt_nxt    = 0;
					data_nxt        = {rx, data_reg[7:1]};
					if (data_cnt == (NBITS-1)) begin
						nxt_state = STOP;
					end else begin
						data_cnt_nxt = data_cnt + 1'b1;
					end
				end else begin
					rx_clk_cntr_nxt = rx_clk_cntr + 1'b1;
				end
			end
		end

		STOP : begin
			if (rx_clk) begin
				if (rx_clk_cntr == INTERVAL_BTW_BITS) begin //TODO counter check 15 or 15 + 7
					rx_clk_cntr_nxt = 0;
					nxt_state = IDLE;
					rx_done_nxt = 1'b1;
				end else begin
					rx_clk_cntr_nxt = rx_clk_cntr + 1'b1;
				end
			end
		end
	endcase
end

assign rx_data = data_reg;
endmodule

module uart_baud #(parameter CLKRATE_MHZ = 200, parameter BAUD_RATE_BPS = 9600)
(
	input clk,
	input rstn,

	output rx_clk,
	output tx_clk
);

/*
 * rx is 16 times oversampled than tx
 * 1 bit period = 1/(baud rate) = 1/(9600) = 104us
 * clock period = 1/200Mhz = 5ns
 * Require 104us/5ns = 20800 cycles to generate tick
 */
localparam RXTICK_COUNT = ((CLKRATE_MHZ * 1000000)/(BAUD_RATE_BPS * 16));
localparam TXTICK_COUNT = ((CLKRATE_MHZ * 1000000)/(BAUD_RATE_BPS));
localparam RX_CNT_WIDTH = $clog2(RXTICK_COUNT);
localparam TX_CNT_WIDTH = $clog2(TXTICK_COUNT);

reg [RX_CNT_WIDTH-1:0] rx_counter;
reg [TX_CNT_WIDTH-1:0] tx_counter;

always @(posedge clk or negedge rstn) begin
	if (!rstn)
		rx_counter <= 1'b0;
	else if (rx_clk)
		rx_counter <= 1'b0;
	else 
		rx_counter <= rx_counter + 1'b1;
end

always @(posedge clk or negedge rstn) begin
	if (!rstn)
		tx_counter <= 1'b0;
	else if (tx_clk)
		tx_counter <= 1'b0;
	else 
		tx_counter <= tx_counter + 1'b1;
end

assign rx_clk = (rx_counter == RXTICK_COUNT);
assign tx_clk = (tx_counter == TXTICK_COUNT);
endmodule

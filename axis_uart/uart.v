module uart #(parameter CLKRATE_MHZ = 200, BAUD_RATE_BPS = 9600, AWIDTH = 4, AXIS_WIDTH = 8)
(
	input  clk, 
	input  rstn,

	input  [AXIS_WIDTH-1:0] s_axis_tdata,
	input  s_axis_tvalid,
	input  s_axis_tlast,
	output s_axis_tready,
  
	output [AXIS_WIDTH-1:0] m_axis_tdata,
	output m_axis_tvalid,
	output m_axis_tlast,
	input  m_axis_tready,

	input  rx,
	output tx,

	// debug ports
	output tx_clk,
  output rx_clk
);

localparam UART_DATA_BITS = 8;

wire valid_data_in_cyc;
reg [AXIS_WIDTH-1:0] fifo_wdata;
reg fifo_wdata_vld;
wire fifo_wren;
wire fifo_rden;
wire fifo_full;
wire fifo_empty;

wire start_tx;											// start transmission data
wire [UART_DATA_BITS-1:0] data2tx;  // data to be transmitted
wire tx_done;		// Completed tranmission

wire rx_clk;
wire tx_clk;

wire [UART_DATA_BITS-1:0] rx_data;
wire rx_done;
wire rx_fifo_ren;
wire rx_fifo_full;
wire rx_fifo_empty;

assign valid_data_in_cyc = s_axis_tvalid && s_axis_tready;
assign s_axis_tready     = !fifo_full;

// flop incoming data
always @(posedge clk) begin
	if (valid_data_in_cyc) begin
		fifo_wdata     <= s_axis_tdata;
  end
end

always @(posedge clk or negedge rstn) begin
	if (!rstn) 
		fifo_wdata_vld <= 0;
	else
		fifo_wdata_vld <= valid_data_in_cyc;
end
assign fifo_wren = fifo_wdata_vld;

// UART Baud Rate generator
uart_baud #(.CLKRATE_MHZ(CLKRATE_MHZ), .BAUD_RATE_BPS(BAUD_RATE_BPS)) u_uart_baud
(
	.clk    (clk),
	.rstn   (rstn),
	.rx_clk (rx_clk),
	.tx_clk (tx_clk)
);

// FIFO at axis input message side
fifo #(.AWIDTH(AWIDTH), .DWIDTH(8)) u_s_axis_fifo
(
	.clk	 (clk),
	.rstn  (rstn),
	.idata (fifo_wdata),
	.wren  (fifo_wren),
	.odata (data2tx),
	.ren   (start_tx),
	.full  (fifo_full),
	.empty (fifo_empty)
);

assign start_tx = !fifo_empty && tx_done;

/*
* UART TX module
* It utlizes same tick as in rx and every 16 rx ticks
* uart sends out a data
*/
uart_tx #(.NBITS(AXIS_WIDTH)) u_uart_tx
(
	.clk      (clk),
	.rstn     (rstn),
	.itx_data (data2tx),
	.start_tx (start_tx),
	.tx_clk   (rx_clk),
	.tx       (tx),
	.tx_done  (tx_done)
);

/*
* UART RX module
*/
uart_rx #(.NBITS(AXIS_WIDTH)) u_uart_rx
(
	.clk      (clk),
	.rstn     (rstn),
  .rx       (rx),
	.rx_clk   (rx_clk),
	.start_rx (!rx_fifo_full),
	.rx_data  (rx_data),
	.rx_done  (rx_done)
);

// AXIS control mechanism
assign rx_fifo_ren = m_axis_tready && !rx_fifo_empty;
assign m_axis_tvalid = !rx_fifo_empty;
assign m_axis_tlast  = m_axis_tvalid;

// UART RX fifo
fifo #(.AWIDTH(AWIDTH), .DWIDTH(8)) u_m_axis_fifo
(
	.clk   (clk),
	.rstn  (rstn),
	.idata (rx_data),
	.wren  (rx_done),
	.odata (m_axis_tdata),
	.ren   (rx_fifo_ren),
	.full  (rx_fifo_full),
	.empty (rx_fifo_empty)
);
endmodule

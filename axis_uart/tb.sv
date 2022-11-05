`timescale 1ns/1ps

module tb ();
	reg clk;
	reg rstn;

	localparam CLKRATE_MHZ   = 200;
	localparam BAUD_RATE_BPS = 115200;
	localparam AWIDTH        = 4;
	localparam AXIS_WIDTH    = 8;

	reg [AXIS_WIDTH-1:0] s_axis_tdata;
	reg s_axis_tvalid;
	reg s_axis_tlast;
	wire s_axis_tready;

	wire [AXIS_WIDTH-1:0] m_axis_tdata;
	wire m_axis_tvalid;
	wire m_axis_tlast;
	reg  m_axis_tready;

	reg rx;
	wire tx;

	wire tx_clk, rx_clk;
	reg [AXIS_WIDTH-1:0] z;
	reg [AXIS_WIDTH-1:0] z1;

	int wait_cycles;
	int idata = 0;
	int err_cnt = 0;
	always #2.5 clk = ~clk;
	int N = 50;

  int send_data[$];

	uart #(.CLKRATE_MHZ(CLKRATE_MHZ), .BAUD_RATE_BPS(BAUD_RATE_BPS), 
		     .AWIDTH(AWIDTH), .AXIS_WIDTH(AXIS_WIDTH)) u_uart 
	(
		.clk           (clk),
		.rstn          (rstn),
		.s_axis_tdata  (s_axis_tdata),
		.s_axis_tvalid (s_axis_tvalid),
		.s_axis_tlast  (s_axis_tlast),
		.s_axis_tready (s_axis_tready),
		.m_axis_tdata  (m_axis_tdata),
		.m_axis_tvalid (m_axis_tvalid),
		.m_axis_tlast  (m_axis_tlast),
		.m_axis_tready (m_axis_tready),
		.rx            (rx),
		.tx            (tx),

		.tx_clk				 (tx_clk),
		.rx_clk				 (rx_clk)
	);

	always @* begin
		rx = tx;
	end


	initial begin
		clk  = 1'b0;
		rstn = 1'b0;

		wait_cycles = $urandom_range(0, 10);
		delay (wait_cycles);
		#1;

		rstn = 1'b1;
		s_axis_tvalid = 1'b0;
		m_axis_tready = 1'b0;
		wait_cycles = $urandom_range(0, 10);
		delay (wait_cycles);
    
		fork 
		begin
		  for (int i = 0; i < N; i++) begin
		  	idata = $urandom_range(0, 255);
		    put(idata, 1);
		  	send_data.push_back(idata);
		  end
		end
    
	  begin
		  for (int i = 0; i < N; i++) begin
		    get (z);
		  	z1 = send_data.pop_front();
				if (z != z1) begin
		  		$display("[ERROR] Mismatch b/w TX=0x%0x RX=0x%0x", z1, z);
					err_cnt++;
				end else
		  		$display("[PASS] TX=0x%0x RX=0x%0x", z1, z);
		  end
		end
	  join

		if (err_cnt)
			$display("[$ERROR] TEST FAILED; Mismatch Count=%0d", err_cnt);
		else
			$display("[$PASS] TEST PASSED;");

		//#1000000;
		$finish;
	end

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
	  //$monitor("[$monitor] time=%0t tx=%0x", $time, tx);
	end



  ///////////////////////////////////////////////////////////////////////////////////////////////
	task put;
		input [AXIS_WIDTH-1:0] data;
		input last;
	begin
		s_axis_tvalid = 1'b1;
		s_axis_tdata  = data;
		s_axis_tlast  = last;
		@(posedge clk);
		while (!s_axis_tready) @(posedge clk);
		$display ("[$push] @time=%0t data=0x%0x last=%0x", $time, data, last);
		s_axis_tvalid = 1'b0;
		s_axis_tlast  = 1'b0;
	end
	endtask

	task get;
		output [AXIS_WIDTH-1:0] data;
	begin
		//$display("[$pop] @time=%0t", $time);
		m_axis_tready = 1'b1;
		while (!m_axis_tvalid) @(posedge clk);
		data = m_axis_tdata;
		$display("[$pop] @time=%0t data=0x%0x", $time, data);
		m_axis_tready = 1'b0;
		@(posedge clk);
	end
	endtask
  
	// wait routine
	task delay;
		input [7:0] dly;
	begin
	  while (dly) begin
	    $display("[$delay] time=%0t dly=%0d", $time, dly);
	  	@(posedge clk);
	  	dly--;
	  end
	end
	endtask
  ///////////////////////////////////////////////////////////////////////////////////////////////

endmodule

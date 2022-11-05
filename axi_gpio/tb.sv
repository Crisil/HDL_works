`timescale 1ns/1ps

module tb ();
  reg  s_axi_aclk;
	reg  s_axi_aresetn;

	localparam C_S_AXI_DATA_WIDTH = 32;
	localparam C_S_AXI_ADDR_WIDTH = 4;

	reg  [C_S_AXI_ADDR_WIDTH-1:0] s_axi_awaddr;
	reg  s_axi_awvalid;
	wire s_axi_awready;

	reg  [C_S_AXI_DATA_WIDTH-1:0] s_axi_wdata;
	reg  s_axi_wvalid;
	wire s_axi_wready;
	reg  [(C_S_AXI_DATA_WIDTH/8)-1:0]s_axi_wstrb;

	wire [1:0] s_axi_bresp;
	wire s_axi_bvalid;
	reg  s_axi_bready;

	reg  [C_S_AXI_ADDR_WIDTH-1:0] s_axi_araddr;
	reg  s_axi_arvalid;
	wire s_axi_arready;
	wire [C_S_AXI_DATA_WIDTH-1:0] s_axi_rdata;
	wire [1:0] s_axi_rresp;
	wire s_axi_rvalid;
	reg  s_axi_rready;

	reg [2:0] s_axi_awport;
	reg [2:0] s_axi_arport;

	reg [C_S_AXI_DATA_WIDTH-1:0] z;

	int wait_cycles;
	int wdata = 0;
	int err_cnt = 0;
	always #2.5 s_axi_aclk = ~s_axi_aclk;
	int N = 50;

  int REGVAL[4];
	int waddr = 0;
	int widx;
	int raddr;
	int ridx;
	int erdata;

	axilite_reg u_axilite_reg
	(
		.s_axi_aclk    (s_axi_aclk),
		.s_axi_aresetn (s_axi_aresetn),

		.s_axi_awaddr  (s_axi_awaddr),
		.s_axi_awvalid (s_axi_awvalid),
		.s_axi_awready (s_axi_awready),
		.s_axi_awport  (s_axi_awport),
		.s_axi_wdata   (s_axi_wdata),
		.s_axi_wvalid  (s_axi_wvalid),
		.s_axi_wready  (s_axi_wready),
		.s_axi_wstrb   (s_axi_wstrb),
		.s_axi_bresp   (s_axi_bresp),
		.s_axi_bvalid  (s_axi_bvalid),
		.s_axi_bready  (s_axi_bready),

		.s_axi_araddr  (s_axi_araddr),
		.s_axi_arvalid (s_axi_arvalid),
		.s_axi_arready (s_axi_arready),
		.s_axi_arport  (s_axi_arport),
		.s_axi_rdata   (s_axi_rdata),
		.s_axi_rresp   (s_axi_rresp),
		.s_axi_rvalid  (s_axi_rvalid),
		.s_axi_rready  (s_axi_rready)
	);

	initial begin
    s_axi_aclk    <= 1'b0;
		s_axi_aresetn <= 1'b0;
		wait_cycles = $urandom_range(0, 10);
		delay (wait_cycles);
		#1;

		s_axi_aresetn <= 1'b1;
		wait_cycles = $urandom_range(0, 10);
		delay (wait_cycles);
		s_axi_awvalid <= 1'b0;
		s_axi_wvalid  <= 1'b0;

		fork 
		  begin
				for (int i = 0; i < N; i++) begin
					widx  = $urandom_range(0, 3);
					waddr = widx * 4;
					wdata = $urandom_range(0, 32'hffff);
					write(waddr, wdata);
          REGVAL[widx] = wdata;
					$display("[$WRITE] time=%0t waddr=0x%0x wdata=0x%0x", $time, waddr, wdata);
				end
		  end

		  begin
				for (int i = 0; i < N; i++) begin
					ridx  = $urandom_range(0, 3);
					raddr = ridx * 4;
					erdata = REGVAL[ridx];
					read(raddr, z);
					if (erdata != z) begin
						err_cnt++;
						$display("[$ERROR] time=%0t addr=0x%0x edata=0x%0x rdata=0x%0x", $time, raddr, erdata, z);
					end else begin
						$display("[$PASS]  time=%0t addr=0x%0x edata=0x%0x rdata=0x%0x", $time, raddr, erdata, z);
					end
				end
		  end

		join

		if (err_cnt)
			$display("[$ERROR] TEST FAILED; Mismatch Count=%0d", err_cnt);
		else
			$display("[$PASS] TEST PASSED;");

		#1000;
		$finish;
	end

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
	  //$monitor("[$monitor] time=%0t tx=%0x", $time, tx);
	end



  ///////////////////////////////////////////////////////////////////////////////////////////////
	task write;
		input [C_S_AXI_ADDR_WIDTH-1:0] addr;
		input [C_S_AXI_DATA_WIDTH-1:0] data;
		s_axi_bready <= 1'b1;
		fork
		  begin
		  	@(posedge s_axi_aclk);
		  	s_axi_awaddr  <= addr;
		  	s_axi_awvalid <= 1'b1;
				//$display ("[$write] -->1 time=%0t >addr = 0x%0x", $time, addr);
		  	while (s_axi_awready == 1'b0) @(posedge s_axi_aclk);
		  	s_axi_awvalid <= 1'b0;
				//$display ("[$write] -->2 time=%0t <addr", $time);
		  end

	    begin
				@(posedge s_axi_aclk);
				s_axi_wdata  <= data;
				s_axi_wvalid <= 1'b1;
				s_axi_wstrb  <= 4'hf;
				//$display ("[$write] -->3 time=%0t >data = 0x%0x", $time, data);
				while (s_axi_wready == 1'b0) @(posedge s_axi_aclk);
				s_axi_wvalid <= 1'b0;
				//$display ("[$write] -->4 time=%0t <data", $time);
	    end

		  begin
				@(posedge s_axi_aclk);
				//$display ("[$write] -->5 time=%0t >wait wvalid", $time);
				while (s_axi_wvalid) @(posedge s_axi_aclk);
				//$display ("[$write] -->6 time=%0t >wait bvalid", $time);
				while (s_axi_bvalid == 1'b0) @(posedge s_axi_aclk);
				//$display ("[$write] -->7 time=%0t <bvalid", $time);
		  end
		join
	endtask

	task read;
		input  [C_S_AXI_ADDR_WIDTH-1:0] addr;
		output [C_S_AXI_DATA_WIDTH-1:0] data;
		s_axi_rready <= 1'b1;
		fork 
		  begin
				@(posedge s_axi_aclk);
        s_axi_araddr  <= addr;
				s_axi_arvalid <= 1'b1;
				//$display("[$read] -->1 time=%0t >addr = 0x%0x", $time, addr);
				while (s_axi_arready == 1'b0) @(posedge s_axi_aclk);
				s_axi_arvalid <= 1'b0;
				//$display("[$read] -->2 time=%0t <addr", $time);
		  end

		  begin
				@(posedge s_axi_aclk);
				//$display("[$read] -->3 time=%0t >wait rvalid", $time);
				while (s_axi_rvalid == 1'b0) @(posedge s_axi_aclk);
				data = s_axi_rdata;
				//$display("[$read] -->4 time=%0t >data = 0x%0x", $time, data);
		  end
		join
	endtask
  
	// wait routine
	task delay;
		input [7:0] dly;
	begin
	  while (dly) begin
	    $display("[$delay] time=%0t dly=%0d", $time, dly);
	  	@(posedge s_axi_aclk);
	  	dly--;
	  end
	end
	endtask
  ///////////////////////////////////////////////////////////////////////////////////////////////

endmodule

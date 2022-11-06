`timescale 1ns/1ps
module tb;
	parameter DWIDTH = 8;
	parameter CLK_HALF_CYC = 5;
	reg clk;
	reg rstn;

	reg [DWIDTH-1:0] i_data;
	reg i_valid;
	wire o_ready;

	wire [DWIDTH-1:0] o_data;
	wire o_valid;
	reg i_ready;

	int wait_cycles;
	int i;

	always #(CLK_HALF_CYC) clk = ~clk;

	pipe #(.DWIDTH(DWIDTH)) u_pipe
	(
		.clk     (clk),
		.rstn    (rstn),
		.i_data  (i_data),
		.i_valid (i_valid),
		.o_ready (o_ready),
		.o_data  (o_data),
		.o_valid (o_valid),
		.i_ready (i_ready)
	);

	initial begin : init
		$display ("1.init time=%0t", $time);
		$dumpfile ("tb.vcd");
		$dumpvars (0, tb);
	end

	initial begin : tst
		$display ("2.test time=%0t", $time);
		clk     = 1;
		rstn    = 0;
		i_valid = 1'b0;
		wait_cycles = $urandom_range(0, 10);
		delay(wait_cycles);
		@(negedge clk);

		rstn    = 1;
		wait_cycles = $urandom_range(0, 10);
		delay(wait_cycles);
		#1
		$display("Start->time=%0t", $time);
		@(negedge clk);

		for (i = 0; i < 10; i=i+1) begin
			put($urandom_range(0, 255));
			@(negedge clk);
		end
    
		wait_cycles = $urandom_range(0, 255);
		delay(wait_cycles);

		#100;
		$display("Finish->time=%0t", $time);
		$finish;
	end

	initial begin : ready
		while (!rstn) @(posedge clk);
			fork
				forever begin
			    begin
			    	if (i_ready && o_valid) begin
			    	  $display("[pop] time=%0t odata=0x%x", $time, o_data);
			      end
			    end

		      begin
			      i_ready = ($urandom_range(0, 10) == 5);
			      @(negedge clk);
		      end
		    end
			join
	end

  ///////////////////////////////////////////////////////////////////////////////////////////////
	task put;
		input [DWIDTH-1:0] data;
	  begin
		  i_valid = 1'b1;
		  i_data  = data;
		  @(negedge clk);
		  while (!o_ready) @(negedge clk);
		  $display ("[$push] @time=%0t data=0x%0x ", $time, data);
		  i_valid = 1'b0;
	  end
	endtask

  task delay;
		input [7:0] dly;
		begin
			while (dly) begin
				//$display("[$delay] time=%0t dly=%0d", $time, dly);
				@(posedge clk);
				dly--;
			end
		end
	endtask

endmodule

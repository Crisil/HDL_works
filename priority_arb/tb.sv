`timescale 1ns/1ps
module tb;
	parameter NUM_INPUTS = 8;
	parameter CLK_HALF_CYC = 5;

	reg clk;
	reg rstn;

	reg  [NUM_INPUTS-1:0] i_grant;
	reg  i_valid;

	wire [NUM_INPUTS-1:0] o_grant;
	wire o_valid;

	int wait_cycles;
	int i;

	always #(CLK_HALF_CYC) clk = ~clk;

	rr_arb u_arb
	(
		.clk     (clk),
		.rstn    (rstn),
		.i_grant (i_grant),
		.i_valid (i_valid),
		.o_grant (o_grant),
		.o_valid (o_valid)
	);

	initial begin : init
		$display ("1. Init time=%0t", $time);
		$dumpfile ("tb.vcd");
		$dumpvars (0, tb);
	end

	initial begin : tst 
		$display ("2. Test->time=%0t", $time);
		clk  = 1;
		rstn = 0;
		i_valid = 1'b0;
		wait_cycles = $urandom_range(1, 10);
		delay(wait_cycles);
		@(negedge clk);

		rstn = 1;
		wait_cycles = $urandom_range(0, 10);
		delay(wait_cycles);

		i_grant = 3;
		i_valid = 1;
		
		wait_cycles = $urandom_range(1, 30);
		delay(wait_cycles);
    
		for (i = 0; i < 10; i=i+1) begin
		  i_grant = $urandom_range(0, 255);
		  delay(wait_cycles);
	  end 
		i_valid = 1'b0;

		#100
		$display("3. Finish->time=%0t", $time);
		$finish;
	end

	//////////////////////////////////////////////////////
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

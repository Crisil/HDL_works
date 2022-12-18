`timescale 1ns/1ps
module tb;
	parameter DWIDTH = 4;
	parameter CLK_HALF_CYC = 5;
	parameter OWIDTH = 2*DWIDTH;

	reg clk;
	reg rstn;

	reg  [DWIDTH-1:0] Xin;
	reg  [DWIDTH-1:0] Yin;
	reg  i_valid;

	wire [OWIDTH-1:0] Z;
	wire o_valid;

	int wait_cycles;
	int i;

	always #(CLK_HALF_CYC) clk = ~clk;

	r2_shift_add_mul #(.DWIDTH(DWIDTH)) u_r2_mul
	(
		.clk     (clk),
		.rstn    (rstn),
		.Xin     (Xin),
		.Yin     (Yin),
		.i_valid (i_valid),
		.Zout    (Z),
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
		
		i_valid = 1'b1;
		Xin = 5;
		Yin = 3;
		@(posedge clk);
		i_valid = 1'b0;
		
		wait_cycles = $urandom_range(1, 30);
		delay(wait_cycles);
    
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

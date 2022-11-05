`timescale 1ns/1ps
module tb;
  parameter DWIDTH  = 8;
	parameter CLK_HALF_CYC = 5;
	parameter MAX_VAL = ((1 << DWIDTH) - 1);

	reg clk;
	reg rstn;

	reg [DWIDTH-1:0] in1;
	reg [DWIDTH-1:0] in2;
	reg ivalid;
	wire [DWIDTH:0] Sum;
	wire Carry;
	wire ovalid;
	wire busy;
 
	int wait_cycles;
	int i;
	int a, b, a1, b1;
	int A[$], B[$];
	


	always #(CLK_HALF_CYC) clk = ~clk;

	adder_wrapper #(.DWIDTH(DWIDTH), .TYP(2), .NUM_STAGES(2)) u_top
	(
		.clk     (clk),
		.rstn    (rstn),
		.in1     (in1),
		.in2     (in2),
		.ivalid  (ivalid),
		.Sum     (Sum[DWIDTH-1:0]),
		.Carry   (Sum[DWIDTH]),
		.ovalid  (ovalid),
		.busy    (busy)
	);

	initial begin : init
	 	$dumpfile ("tb.vcd");
		$dumpvars (0, tb);
		$monitor ("[monitor] time=%0t Ovalid=%x Sum=%x", $time, ovalid, Sum);
	end

	initial begin : tst
		clk     = 1;
		rstn    = 0;
		ivalid  = 1'b0;
		wait_cycles = $urandom_range(0, 10);
		delay(wait_cycles);
		#1

    rstn = 1;
    wait_cycles = $urandom_range(0, 10);
		delay(wait_cycles);
		#1

		for (i = 0; i < 10; i=i+1) begin
			a = $urandom_range(0, MAX_VAL);
			b = $urandom_range(0, MAX_VAL);
		  add (a, b);
		  wait_cycles = $urandom_range(10, 50);
	  end
		delay(wait_cycles);

		$display("4.time=%0t", $time);
		$finish;
	end

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

	task add;
		input [7:0] i1;
		input [7:0] i2;
	begin
		while (busy) @(posedge clk);
		#1
		in1 = i1;
		in2 = i2;
		ivalid = 1'b1;
		$display ("[add] %0t in1=%x in2=%x", $time, in1, in2);
		#(2 * CLK_HALF_CYC);
		ivalid = 1'b0;
		//#(DWIDTH * CLK_HALF_CYC + 2);
	end
	endtask
endmodule

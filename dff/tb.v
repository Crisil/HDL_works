module tb();
  reg clk;
	reg rst_n;
	reg d;
	reg e;
	wire q;
	wire qr;

	dff u_dff 
	(
		.clk   (clk),
		.rst_n (rst_n),
		.e     (e),
		.d     (d),
		.q     (q),
		.qr    (q)
	);

	initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
		clk   = 1'b0;
		rst_n = 1'b0;
		d     = 1'b0;
		e     = 1'b0;

		#12
		rst_n = 1'b1;

		#28
		d = 1'b1;
		e = 1'b1;
		#8
		e = 1'b0;

		#500
		$finish;
	end

	always #5 clk = ~clk;
endmodule

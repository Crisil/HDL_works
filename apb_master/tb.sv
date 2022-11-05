module tb();
  reg clk;
	reg rst_n;
	reg [1:0] cmd_i;

	wire psel_o;
	wire penable_o;
	wire [31:0] paddr_o;
	wire pwrite_o;
	wire [31:0] pwdata_o;

	reg  pready_i;
	reg  [31:0] prdata_i;

	apb_master u_apb_master
	(
		.clk       (clk),
		.rst_n     (rst_n),
		.cmd_i     (cmd_i),
		.psel_o    (psel_o),
		.penable_o (penable_o),
		.paddr_o   (paddr_o),
		.pwrite_o  (pwrite_o),
		.pwdata_o  (pwdata_o),
		.pready_i  (pready_i),
		.prdata_i  (prdata_i)
	);

	int wait_cycles;
	always #5 clk = ~clk;

	always begin
		pready_i = 1'b0;
		wait_cycles = $urandom_range(0, 10);
	  while(wait_cycles) begin
			@(posedge clk);
			wait_cycles--;
  	end
		pready_i = 1'b1;
		@(posedge clk);
	end

	initial begin
		rst_n <= 1'b0;
		clk   <= 1'b0;
		cmd_i <= 2'b00;
		prdata_i <= 32'h0;
		@(posedge clk);
		@(posedge clk);

		rst_n <= 1'b1;
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);

		for (int i = 0; i < 10; i++) begin
			cmd_i <= i%2 ? 2'b10 : 2'b01;
			prdata_i <= $urandom_range(0, 4'hF);
			while(~pready_i | ~psel_o) @(posedge clk);
			@(posedge clk);
		end
		$finish;
	end

  initial begin
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
	end
endmodule

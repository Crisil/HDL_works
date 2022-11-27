`timescale 1ns/1ns
module tb;
  parameter CLK_HALF_CYC = 5;
	parameter DWIDTH = 16;
	parameter OWIDTH = 2 * DWIDTH;

	reg rstn;
	reg clk;

	reg signed [DWIDTH-1:0] i_data;
	reg i_valid;
	wire o_ready;

	wire [OWIDTH-1:0] o_data;
	wire o_valid;
	reg i_ready;

	int wait_cycles;
	int i;

	reg [4:0] state_reg;
	reg [3:0] cntr;

	// 200khz signal
	parameter wvfm_perido = 4'd4;
	parameter SI   = 5'd0;
	parameter SS0  = 5'd1;
	parameter SS1  = 5'd2;
	parameter SS2  = 5'd3;
	parameter SS3  = 5'd4;
	parameter SS4  = 5'd5;
	parameter SS5  = 5'd6;
	parameter SS6  = 5'd7;
	parameter SS7  = 5'd8;

	always #(CLK_HALF_CYC) clk = ~clk;

	fir #(.DWIDTH(DWIDTH)) u_fir
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
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
	end

	initial begin : tst
		clk  = 1'b1;
		rstn = 0;
		wait_cycles = $urandom_range(0, 10);
		delay(wait_cycles);
		#1

		rstn = 1'b1;
		delay(wait_cycles);
    
		#10000
		$display("time=%0t", $time);
		$finish;
	end

	always @(posedge clk or negedge rstn) begin
		if (!rstn) begin
			cntr      <= 4'd0;
			i_data    <= 16'd0;
			state_reg <= SI;
		end else begin
			case (state_reg) 
				SI : begin
					cntr      <= 4'd0;
					i_data    <= 16'h0;
					state_reg <= SS0;
				end

				SS0 : begin
					i_data <= 16'h0;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS1;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS0;
					end
				end
				
				SS1 : begin
					i_data <= 16'h5A7E;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS2;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS1;
					end
				end
				
				SS2 : begin
					i_data <= 16'h7FFF;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS3;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS2;
					end
				end
				
				SS3 : begin
					i_data <= 16'h5A7E;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS4;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS3;
					end
				end

				SS4 : begin
					i_data <= 16'h0;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS5;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS4;
					end
				end

				SS5 : begin
					i_data <= 16'hA582;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS6;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS5;
					end
				end
				
				SS6 : begin
					i_data <= 16'h8000;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS7;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS6;
					end
				end
				
				SS7 : begin
					i_data <= 16'hA582;
					if (cntr == wvfm_perido) begin
						cntr      <= 4'd0;
						state_reg <= SS0;
					end else begin
						cntr      <= cntr + 1'b1;
						state_reg <= SS7;
					end
				end

			endcase
		end
	end


/////////////////////////////////////////////////////
	task delay;
		input [7:0] dly;
	  begin
			while(dly) begin
				@(posedge clk);
				dly--;
			end
	  end
	endtask
endmodule

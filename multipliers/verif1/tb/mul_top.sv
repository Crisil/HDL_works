`ifndef MUL_TOP
`define MUL_TOP
`include "uvm_macros.svh"
`include "mul_if.sv"
import uvm_pkg::*;

module mul_top;
  import mul_test_list::*;

	// Declaration of local fields
	parameter DWIDTH = 8;
	parameter CLK_HALF_CYC = 5;

	// instantiate interface
	mul_if dut_if();

	// clock generation
	initial begin
		dut_if.clk = '0;
		forever #(CLK_HALF_CYC) dut_if.clk = ~dut_if.clk;
	end

	// reset generation
	initial begin
		dut_if.rstn = '0;
		#(CLK_HALF_CYC * 5) dut_if.rstn = '1;
	end

	// Multiplier instance
  r2_shift_add_mul DUT
	(
		.clk     (dut_if.clk),
		.rstn    (dut_if.rstn),
		.Xin     (dut_if.Xin),
		.Yin     (dut_if.Yin),
		.i_valid (dut_if.i_valid),
		.Zout    (dut_if.Zout),
		.o_valid (dut_if.o_valid)
	);
  
	// start the test
	initial begin
		run_test();
	end
  
	// register with factory
	initial begin
		uvm_config_db#(virtual mul_if)::set(uvm_root::get(),"*", "vif", dut_if);
	end
endmodule
`endif

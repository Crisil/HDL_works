`ifndef MUL_IF
`define MUL_IF

`define ILEN  7:0
`define OLEN 15:0
interface mul_if;
	logic clk;
	logic rstn;
	logic [7:0] Xin;
	logic [7:0] Yin;
	logic i_valid;
	logic [15:0] Zout;
	logic o_valid;

	////////////////////////////////
	// Clocking Blocks for driver
	clocking dr_cb @(posedge clk);
		output Xin;
		output Yin;
		output i_valid;
		input  Zout;
		input  o_valid;
	endclocking
	modport DRV (clocking dr_cb, input clk, input rstn);

	////////////////////////////////
	//CB monitor
	clocking rc_cb @(negedge clk);
		input Xin;
		input Yin;
		input i_valid;
		input Zout;
		input o_valid;
	endclocking
	modport RCV (clocking rc_cb, input clk, input rstn);
endinterface

`endif

`ifndef MUL_AGENT_PKG
`define MUL_AGENT_PKG
package mul_agent_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"
	
	`include "mul_defines.svh"
	`include "mul_transaction.sv"
	`include "mul_sequencer.sv"
	`include "mul_driver.sv"
	`include "mul_monitor.sv"
	`include "mul_agent.sv"
endpackage
`endif

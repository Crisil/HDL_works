`ifndef MUL_ENV_PKG
`define MUL_ENV_PKG
package mul_env_pkg;
	import uvm_pkg::*;
	`include "uvm_macros.svh"

	import mul_agent_pkg::*;
	import mul_model_pkg::*;

	`include "mul_sb.sv"
	`include "mul_env.sv"
endpackage
`endif

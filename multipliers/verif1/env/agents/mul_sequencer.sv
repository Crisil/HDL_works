`ifndef MUL_SEQUENCER
`define MUL_SEQUENCER

class mul_sequencer extends uvm_sequencer#(mul_transaction);
	`uvm_component_utils(mul_sequencer)

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction
endclass
`endif

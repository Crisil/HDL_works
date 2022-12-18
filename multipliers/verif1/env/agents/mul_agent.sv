`ifndef MUL_AGENT
`define MUL_AGENT

class mul_agent extends uvm_agent;
	`uvm_component_utils(mul_agent)

	mul_driver    drv;
	mul_monitor   mon;
	mul_sequencer sqr;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		drv = mul_driver::type_id::create("drv", this);
		mon = mul_monitor::type_id::create("mon", this);
		sqr = mul_sequencer::type_id::create("sqr", this);
	endfunction

	function void connect_phase(uvm_phase phase);
	    super.connect_phase(phase);
		drv.seq_item_port.connect(sqr.seq_item_export);
	endfunction
endclass
`endif

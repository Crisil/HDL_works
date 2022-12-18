`ifndef MUL_BASIC_TEST
`define MUL_BASIC_TEST
class mul_basic_test extends uvm_test;
	`uvm_component_utils(mul_basic_test)

	mul_env env;
	mul_basic_seq seq;

	function new(string name="mul_basic_test", uvm_component parent=null);
		super.new(name, parent);
	endfunction

  virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		env = mul_env::type_id::create("env", this);
		seq = mul_basic_seq::type_id::create("seq", this);
	endfunction

	task run_phase(uvm_phase phase);
		phase.raise_objection(this);
		seq.start(env.agent.sqr);
		phase.drop_objection(this);
	endtask
endclass
`endif

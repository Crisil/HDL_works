`ifndef MUL_ENV
`define MUL_ENV

class mul_env extends uvm_env;
	`uvm_component_utils(mul_env)

	mul_agent agent;
	mul_model r_mod;
	mul_sb    sb;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		agent = mul_agent::type_id::create("agent", this);
		r_mod = mul_model::type_id::create("r_mod", this);
		sb    = mul_sb::type_id::create("sb", this);
	endfunction
  
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		//agent.drv.tr_drv_ap.connect(r_mod.tr_drv_export);
		agent.mon.tr_mon_ap.connect(sb.tr_mon_export);
		r_mod.tr_rm_ap.connect(sb.tr_rm_export);
	endfunction

endclass
`endif

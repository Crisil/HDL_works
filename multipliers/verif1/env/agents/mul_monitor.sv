`ifndef MUL_MONITOR
`define MUL_MONITOR

class mul_monitor extends uvm_monitor;

	`uvm_component_utils(mul_monitor)

	virtual mul_if vif;
	mul_transaction tr;
	uvm_analysis_port #(mul_transaction) tr_mon_ap;

	function new(string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual mul_if)::get(this, "", "vif", vif))
			`uvm_fatal("NO_VIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
		tr_mon_ap = new("tr_mon_ap", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			mon();
			tr_mon_ap.write(tr);
		end
	endtask

	task mon();
		wait(vif.rstn);
		tr = new();
		repeat(1) @(vif.rc_cb);
		wait(vif.rc_cb.o_valid == '1);
		tr.Xin     = vif.rc_cb.Xin;
		tr.Yin     = vif.rc_cb.Yin;
		tr.i_valid = vif.rc_cb.i_valid;
		tr.o_valid = vif.rc_cb.o_valid;
		tr.Zout    = vif.rc_cb.Zout;
		`uvm_info(get_full_name(), $sformatf("Zout: %0d", tr.Zout), UVM_NONE)
	endtask
endclass
`endif

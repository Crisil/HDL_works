`ifndef MUL_SB
`define MUL_SB
class mul_sb extends uvm_scoreboard;
	`uvm_component_utils(mul_sb)
	uvm_analysis_export #(mul_transaction) tr_rm_export;
	uvm_analysis_export #(mul_transaction) tr_mon_export;

	uvm_tlm_analysis_fifo #(mul_transaction) tr_rm_afifo;
	uvm_tlm_analysis_fifo #(mul_transaction) tr_mon_afifo;

	mul_transaction tr_exp_q[$], tr_q[$];
	mul_transaction tr_exp, tr;
	bit error;

	function new(string name="mul_sb", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tr_rm_export  = new("tr_rm_export", this);
		tr_mon_export = new("tr_mon_export", this);
		tr_rm_afifo   = new("tr_rm_afifo", this);
		tr_mon_afifo  = new("tr_mon_afifo", this);
	endfunction

	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		tr_rm_export.connect(tr_rm_afifo.analysis_export);
		tr_mon_export.connect(tr_mon_afifo.analysis_export);
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
		  tr_exp = new();
		  tr = new();
		  tr_rm_afifo.get(tr_exp);
			tr_mon_afifo.get(tr);
			tr_exp_q.push_back(tr_exp);
			tr_q.push_back(tr);

			compare();
		end
	endtask

	function void compare();
		mul_transaction tr_e, tr_m;		
		if (tr_exp_q.size()) begin
		    tr_e = new();
			tr_e = tr_exp_q.pop_front();
			if (tr_q.size()) begin
			    tr_m = new();
				tr_m = tr_q.pop_front();
				`uvm_info("compare", $sformatf("Xin: %0d Yin: %0d Zout: %0d", 
					                    tr_m.Xin, tr_m.Yin, tr_e.Zout), UVM_NONE)
			end
		end
	endfunction

endclass
`endif

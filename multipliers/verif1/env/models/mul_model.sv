`ifndef MUL_MODEL
`define MUL_MODEL

class mul_model extends uvm_component;
	`uvm_component_utils(mul_model)

	uvm_analysis_export #(mul_transaction) tr_drv_export;
	uvm_tlm_analysis_fifo #(mul_transaction) tr_drv_afifo;
	uvm_analysis_port #(mul_transaction) tr_rm_ap;

	mul_transaction tr_exp;; // expected transaction
	mul_transaction tr_fifo_rcv;

	function new(string name="mul_model", uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		tr_drv_export = new("tr_drv_export", this);
		tr_drv_afifo  = new("tr_drv_afifo", this);
		tr_rm_ap      = new("tr_rm_ap", this);
	endfunction
  
	function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		tr_drv_export.connect(tr_drv_afifo.analysis_export);
	endfunction

	task run_phase(uvm_phase phase);
		forever begin
		  tr_exp = new();
		  tr_fifo_rcv = new();
		  tr_drv_afifo.get(tr_fifo_rcv);
		  this.tr_exp = tr_fifo_rcv;
		  tr_exp.Zout = tr_exp.Xin * tr_exp.Yin;
		  tr_rm_ap.write(tr_exp);
	  end
	endtask

endclass
`endif

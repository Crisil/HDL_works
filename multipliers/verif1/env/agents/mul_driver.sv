`ifndef MUL_DRIVER
`define MUL_DRIVER

class mul_driver extends uvm_driver #(mul_transaction);
	`uvm_component_utils(mul_driver)

  virtual mul_if vif;
	uvm_analysis_port #(mul_transaction) tr_drv_ap;

  function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if (!uvm_config_db#(virtual mul_if)::get(this, "", "vif", vif)) begin
			`uvm_fatal("NO_VIF", {"virtual interface must be set for: ", get_full_name(), ".vif"});
		tr_drv_ap = new("tr_drv_ap", this);
		end
	endfunction

	task run_phase(uvm_phase phase);
		reset();
		forever begin
			req = new();	
			rsp = new();	
			seq_item_port.get_next_item(req);
			`uvm_info(get_full_name(), $sformatf("Xin: %0d Yin: %0d", req.Xin, req.Yin), UVM_NONE)
			// TODO
			//$cast(rsp, req.clone());
			//rsp.set_id_info(req);
			//tr_drv_ap.write(rsp);
			drive();			
			repeat(10) @(vif.dr_cb);			
			seq_item_port.item_done();
		end
	endtask

	task drive();
		wait (vif.rstn);
		@(vif.dr_cb);
		vif.Xin     <= req.Xin;
		vif.Yin     <= req.Yin;
		vif.i_valid <= req.i_valid;
		@(vif.dr_cb);
		vif.i_valid <= '0;		
		wait(vif.o_valid == '1);				
	endtask

	task reset();
		vif.Xin     <= '0; 
		vif.Yin     <= '0; 
		vif.i_valid <= '0; 
	endtask
endclass
`endif

`ifndef MUL_BASIC_SEQ
`define MUL_BASIC_SEQ
class mul_basic_seq extends uvm_sequence #(mul_transaction);
	`uvm_object_utils(mul_basic_seq)

	function new(string name="mul_basic_seq");
		super.new(name);
	endfunction

	virtual task body();
		for (int i = 0; i < `NUM_TRANS; i++) begin
			req = mul_transaction::type_id::create("req");
			start_item(req);
			assert(req.randomize());
			req.i_valid = '1;
			//`uvm_info(get_full_name(), $sformatf("Xin: %0d Yin: %0d", req.Xin, req.Yin), UVM_NONE)
			finish_item(req);
		end
	endtask
endclass
`endif

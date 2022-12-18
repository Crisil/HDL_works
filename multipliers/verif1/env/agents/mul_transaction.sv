`ifndef MUL_TRANSACTION
`define MUL_TRANSACTION

class mul_transaction extends uvm_sequence_item;
	rand bit [7:0] Xin;
	rand bit [7:0] Yin;
	bit i_valid;
	bit [15:0] Zout;
	bit o_valid;

	`uvm_object_utils_begin (mul_transaction)
	    `uvm_field_int (Xin, UVM_ALL_ON)
		`uvm_field_int (Yin, UVM_ALL_ON)
		`uvm_field_int (i_valid, UVM_ALL_ON)
		`uvm_field_int (Zout, UVM_ALL_ON)
		`uvm_field_int (o_valid, UVM_ALL_ON)
	`uvm_object_utils_end

	function new(string name="mul_transaction");
		super.new(name);
	endfunction

	constraint X_c {Xin <= 15;}
	constraint Y_c {Yin <= 15;}
endclass
`endif

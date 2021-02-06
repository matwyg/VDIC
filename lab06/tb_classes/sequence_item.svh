class sequence_item extends uvm_sequence_item;

	rand bit[31:0] A;
	rand bit[31:0] B;
	rand op_t op;
    rand bit [2:0] err_flags;

   constraint constr { A dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};
                 	 B dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1}; 
				 	op != RST;}


	function new(string name = "sequence_item");
		super.new(name);
	endfunction : new

	`uvm_object_utils_begin(sequence_item)
		`uvm_field_int(A, UVM_ALL_ON)
		`uvm_field_int(B, UVM_ALL_ON)
		`uvm_field_enum(op_t, op, UVM_ALL_ON)
        `uvm_field_int(err_flags, UVM_ALL_ON)
	`uvm_object_utils_end
	

	function string convert2string();
		string s;
		s = $sformatf("A: %8h  B: %8h op: %s err_flags: %b",
                        A, B, op.name(), err_flags);
		return s;
	endfunction : convert2string

endclass : sequence_item
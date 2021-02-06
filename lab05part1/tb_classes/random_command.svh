class random_command extends uvm_transaction;
	`uvm_object_utils(random_command)

	rand bit [31:0] A;
	rand bit [31:0] B;
	rand op_t op;
	rand bit [2:0] err_flags;

	constraint data { A dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1};
                      B dist {32'h0000_0000:=1, [32'h0000_0001 : 32'hFFFF_FFFE]:=1, 32'hFFFF_FFFF:=1}; 
   					  op != RST; }


	virtual function void do_copy(uvm_object rhs);
		random_command copied_command_h;

		if(rhs == null)
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

		super.do_copy(rhs); // copy all parent class data

		if(!$cast(copied_command_h,rhs))
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

		A = copied_command_h.A;
		B = copied_command_h.B;
		op = copied_command_h.op;
		err_flags = copied_command_h.err_flags;

	endfunction : do_copy

	virtual function random_command clone_me();
		random_command clone;
		uvm_object tmp;

		tmp = this.clone();
		$cast(clone, tmp);
		return clone;
	endfunction : clone_me

	virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		random_command compared_command_h;
		bit   same;

		if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
				"Tried to do comparison to a null pointer");

		if (!$cast(compared_command_h,rhs))
			same = 0;
		else
			same = super.do_compare(rhs, comparer) &&
			(compared_command_h.A == A) &&
			(compared_command_h.B == B) &&
			(compared_command_h.op == op) &&
			(compared_command_h.err_flags == err_flags);

		return same;
	endfunction : do_compare

	virtual function string convert2string();
		string s;
		s = $sformatf("A: %2h  B: %2h op: %s, err_flags: %b",
			A, B, op.name(), err_flags);
		return s;
	endfunction : convert2string

	function new (string name = "");
		super.new(name);
	endfunction : new

endclass : random_command

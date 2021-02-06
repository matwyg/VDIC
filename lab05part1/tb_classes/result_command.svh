class result_command extends uvm_transaction;
	`uvm_object_utils(result_command)

	bit [31:0] C;
	bit [3:0] flags;
	bit [2:0] err_flags;


	virtual function void do_copy(uvm_object rhs);
		result_command copied_command_h;

		if(rhs == null)
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy from a null pointer")

		super.do_copy(rhs); // copy all parent class data

		if(!$cast(copied_command_h,rhs))
			`uvm_fatal("COMMAND TRANSACTION", "Tried to copy wrong type.")

		C = copied_command_h.C;
		flags = copied_command_h.flags;
		err_flags = copied_command_h.err_flags;

	endfunction : do_copy

	virtual function result_command clone_me();
		result_command clone;
		uvm_object tmp;

		tmp = this.clone();
		$cast(clone, tmp);
		return clone;
	endfunction : clone_me

	virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
		result_command compared_command_h;
		bit   same;

		if (rhs==null) `uvm_fatal("RANDOM TRANSACTION",
				"Tried to do comparison to a null pointer");

		if (!$cast(compared_command_h,rhs))
			same = 0;
		else
			same = super.do_compare(rhs, comparer) &&
			(compared_command_h.C == C) &&
			(compared_command_h.flags == flags) &&
			(compared_command_h.err_flags == err_flags);

		return same;
	endfunction : do_compare

	virtual function string convert2string();
		string s;
		s = $sformatf("C: %2h  flags: %b err_flags: %b",
			C, flags, err_flags);
		return s;
	endfunction : convert2string

	function new (string name = "");
		super.new(name);
	endfunction : new

endclass : result_command

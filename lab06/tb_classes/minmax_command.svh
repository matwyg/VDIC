class minmax_command extends random_command;
	`uvm_object_utils(minmax_command)

	constraint minmax { A inside {32'h0000_0000, 32'hFFFF_FFFF};
						B inside {32'h0000_0000, 32'hFFFF_FFFF};
						op != RST;}

	function new (string name = "");
		super.new(name);
	endfunction : new

endclass : minmax_command

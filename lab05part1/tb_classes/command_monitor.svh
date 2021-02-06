class command_monitor extends uvm_component;
	`uvm_component_utils(command_monitor)

	virtual mtm_Alu_bfm bfm;

	uvm_analysis_port #(random_command) ap;

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
			$fatal(1, "Failed to get BFM");
		bfm.command_monitor_h = this;
		ap = new("ap",this);
	endfunction : build_phase

	function void write_to_monitor(random_command cmd);
		//   $display("COMMAND MONITOR: B: %0h  A: %0h  op: %0b  err_flags: %0b", cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags);
		`uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %2h  B: %2h  op: %s  err_flags: %b",
				cmd.A, cmd.B, cmd.op.name(), cmd.err_flags), UVM_HIGH);
		ap.write(cmd);
	endfunction : write_to_monitor

	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction

endclass : command_monitor
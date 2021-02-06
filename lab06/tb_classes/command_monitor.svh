class command_monitor extends uvm_component;
	`uvm_component_utils(command_monitor)

	virtual mtm_Alu_bfm bfm;
	uvm_analysis_port #(sequence_item) ap;


	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction


	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
			`uvm_fatal("COMMAND MONITOR", "Failed to get BFM")
		ap = new("ap",this);
	endfunction : build_phase


	function void connect_phase(uvm_phase phase);
		bfm.command_monitor_h = this;
	endfunction : connect_phase


	function void write_to_monitor(bit[31:0] A, bit[31:0] B, op_t op, bit[2:0] err_flags);
		sequence_item cmd;
		`uvm_info("COMMAND MONITOR",$sformatf("MONITOR: A: %8h  B: %8h  op: %s",
				A, B, op.name()), UVM_HIGH);
		cmd    = new("cmd");
		cmd.A  = A;
		cmd.B  = B;
		cmd.op = op;
		cmd.err_flags = err_flags;
		ap.write(cmd);
	endfunction : write_to_monitor

endclass : command_monitor
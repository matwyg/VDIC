class driver extends uvm_driver #(sequence_item);
	`uvm_component_utils(driver)

	virtual mtm_Alu_bfm bfm;
	
	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction : new

	function void build_phase(uvm_phase phase);
		if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
			`uvm_fatal("DRIVER", "Failed to get BFM")
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		sequence_item cmd;

		void'(begin_tr(cmd));
		
		forever begin : cmd_loop
			seq_item_port.get_next_item(cmd);
			bfm.send_cmd(cmd.A, cmd.B, cmd.op, cmd.err_flags);
			seq_item_port.item_done();
		end : cmd_loop
		
		end_tr(cmd);
		
	endtask : run_phase

endclass : driver


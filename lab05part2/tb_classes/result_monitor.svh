class result_monitor extends uvm_component;
    `uvm_component_utils(result_monitor)

	virtual mtm_Alu_bfm bfm;
	
    uvm_analysis_port #(result_command) ap;

    function void write_to_monitor(result_command r);
    //    $display ("RESULT MONITOR: err_flags: %0b  C: %0h  flags: %0b", r.err_flags, r.C, r.flags);
        ap.write(r);
    endfunction : write_to_monitor

    function void build_phase(uvm_phase phase);
        
		mtm_Alu_agent_config mtm_Alu_agent_config_h;

		if(!uvm_config_db #(mtm_Alu_agent_config)::get(this, "","config", mtm_Alu_agent_config_h))
			`uvm_fatal("RESULT MONITOR", "Failed to get CONFIG")

		mtm_Alu_agent_config_h.bfm.result_monitor_h = this;
        ap = new("ap",this);
    endfunction : build_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : result_monitor

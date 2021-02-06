class mtm_Alu_agent_config;

	virtual mtm_Alu_bfm bfm;
	protected  uvm_active_passive_enum     is_active;

	function new (virtual mtm_Alu_bfm bfm, uvm_active_passive_enum is_active);
		this.bfm = bfm;
		this.is_active = is_active;
	endfunction : new

	function uvm_active_passive_enum get_is_active();
		return is_active;
	endfunction : get_is_active

endclass : mtm_Alu_agent_config
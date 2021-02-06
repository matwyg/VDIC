class env_config;

	virtual mtm_Alu_bfm class_bfm;
	virtual mtm_Alu_bfm module_bfm;


	function new(virtual mtm_Alu_bfm class_bfm, virtual mtm_Alu_bfm module_bfm);
		this.class_bfm = class_bfm;
		this.module_bfm = module_bfm;
	endfunction : new

endclass : env_config
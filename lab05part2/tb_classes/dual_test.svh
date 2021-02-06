class dual_test extends uvm_test;
	`uvm_component_utils(dual_test)

	env env_h;

	function new (string name, uvm_component parent);
		super.new(name,parent);
	endfunction : new


	function void build_phase(uvm_phase phase);

		virtual mtm_Alu_bfm class_bfm;
		virtual mtm_Alu_bfm module_bfm;

		env_config env_config_h;

		if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(this, "","class_bfm", class_bfm))
			`uvm_fatal("DUAL TEST", "Failed to get CLASS BFM");
		if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(this, "","module_bfm", module_bfm))
			`uvm_fatal("DUAL TEST", "Failed to get MODULE BFM");

		env_config_h = new(.class_bfm(class_bfm), .module_bfm(module_bfm));

		uvm_config_db #(env_config)::set(this, "env_h*", "config", env_config_h);

		env_h        = env::type_id::create("env_h",this);

	endfunction : build_phase


	function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		this.print();
	endfunction : start_of_simulation_phase

endclass


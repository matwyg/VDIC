virtual class tester extends uvm_component;
	`uvm_component_utils(tester)

	uvm_put_port #(random_command) command_port;

	function new (string name, uvm_component parent);
		super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
		command_port = new("command_port", this);
	endfunction : build_phase

	task run_phase(uvm_phase phase);
		random_command command;

		phase.raise_objection(this);

		command = new("command");
		command.op = RST; //reset alu
		command_port.put(command);
		#20
		repeat (200) begin
			command = random_command::type_id::create("command");
			if(!command.randomize())
				`uvm_fatal("TESTER", "Randomization failed");
			command_port.put(command);
		end

		#500;
		phase.drop_objection(this);
	endtask : run_phase

endclass : tester


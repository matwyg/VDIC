/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 12:09:34 AM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

virtual class base_tester extends uvm_component;
    `uvm_component_utils(base_tester)

    uvm_put_port #(command_s) command_port;

	function new (string name, uvm_component parent);
        super.new(name, parent);
	endfunction

    function void build_phase(uvm_phase phase);
        command_port = new("command_port", this);
    endfunction : build_phase
	
	pure virtual function op_t get_op();
	pure virtual function [31:0] get_data();
	pure virtual function [2:0] get_err_flags();

	task run_phase(uvm_phase phase);
		bit [31:0] B;
		bit [31:0] A;
		bit [2:0] op_set_bit;
		bit [2:0] err_flags;
		command_s command;

		phase.raise_objection(this);
		command.op_set_bit = 3'b111; //reset alu
        command_port.put(command);
		#70
		repeat (10) begin : random_loop
			command.B = get_data();
			command.A = get_data();
			command.op_set_bit = get_op();
			command.err_flags = get_err_flags();
			command_port.put(command);
		end : random_loop
		#500;
		phase.drop_objection(this);
	endtask : run_phase
	
endclass : base_tester


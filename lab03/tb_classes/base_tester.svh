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

	virtual mtm_Alu_bfm bfm;

	function new (string name, uvm_component parent);
        super.new(name, parent);
	endfunction

	function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase
	
	pure virtual function op_t get_op();

	pure virtual function [31:0] get_data();

	// protected function op_t get_op();
	// 	bit [2:0] op_choice;
	// 	op_choice = $random;
	// 	case (op_choice)
	// 		3'b000 : return AND;
	// 		3'b001 : return OR;
	// 		3'b010 : return ADD;
	// 		3'b011 : return SUB;
	// 		3'b100 : return AND;
	// 		3'b101 : return OR;
	// 		3'b110 : return ADD;
	// 		3'b111 : return SUB;
	// 	endcase // case (op_choice)
	// endfunction : get_op

	pure virtual function [2:0] get_err_flags();

	// protected function [2:0] get_err_flags();
	// 	bit [2:0] err_choice;
	// 	err_choice = $random;
	// 	case (err_choice)
	// 		3'b000 : return 3'b001;
	// 		3'b001 : return 3'b010;
	// 		3'b010 : return 3'b100;
	// 		default : return 3'b000;
	// 	endcase
	// endfunction


	task run_phase(uvm_phase phase);
		bit [31:0] B;
		bit [31:0] A;
		op_t op;
		bit [2:0] err_flags;

		phase.raise_objection(this);

//		#20;
		bfm.reset_alu();
//		#30;

		repeat (200) begin : random_loop
			B = get_data();
			A = get_data();
			op = get_op();
			err_flags = get_err_flags();
			bfm.send_cmd(B, A, op, err_flags);
		end : random_loop

//		#2000;
//		bfm.reset_alu();
//		#30;
		phase.drop_objection(this);
		
	endtask : run_phase
	
endclass : base_tester


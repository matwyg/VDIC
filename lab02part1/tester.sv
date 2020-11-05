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

module tester(mtm_Alu_bfm bfm);
	import mtm_Alu_pkg::*;

	function op_t get_op();
		bit [2:0] op_choice;
		op_choice = $random;
		case (op_choice)
			3'b000 : return AND;
			3'b001 : return OR;
			3'b010 : return ADD;
			3'b011 : return SUB;
			3'b100 : return AND;
			3'b101 : return OR;
			3'b110 : return ADD;
			3'b111 : return SUB;
		endcase // case (op_choice)
	endfunction : get_op

	function [2:0] get_err_flags();
		bit [2:0] err_choice;
		err_choice = $random;
		case (err_choice)
			3'b000 : return 3'b001;
			3'b001 : return 3'b010;
			3'b010 : return 3'b100;
			default : return 3'b000;
		endcase
	endfunction


	initial begin : tester
		bit [31:0] B;
		bit [31:0] A;
		op_t op;
		bit [2:0] err_flags;

		#20;
		bfm.reset_alu();
		#30;

		repeat (50) begin : tester_00_FF
			B = 32'd0;
			A = 32'd0;
			op = get_op();
			bfm.send_cmd(B, A, op, 3'b000);
		end

		repeat (50) begin : tester_00_FF_2
			B = 32'hFFFF_FFFF;
			A = 32'd0;
			op = get_op();
			bfm.send_cmd(B, A, op, 3'b000);
		end

		repeat (50) begin : tester_00_FF_3
			B = 32'd0;
			A = 32'hFFFF_FFFF;
			op = get_op();
			bfm.send_cmd(B, A, op, 3'b000);
		end

		repeat (50) begin : tester_00_FF_4
			B = 32'hFFFF_FFFF;
			A = 32'hFFFF_FFFF;
			op = get_op();
			bfm.send_cmd(B, A, op, 3'b000);
		end

		repeat (100) begin : tester_main
			B = $random;
			A = $random;
			op = get_op();
			err_flags = get_err_flags();
			bfm.send_cmd(B, A, op, err_flags);
		end

		#2000;
		bfm.reset_alu();
		#30 $finish;
	end
endmodule

/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 12:15:30 AM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

class scoreboard extends uvm_subscriber #(result_s);
    `uvm_component_utils(scoreboard)

	virtual mtm_Alu_bfm bfm;
	uvm_tlm_analysis_fifo #(command_s) cmd_f;
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

	function void write (result_s t);
		bit [31:0] C_expected;
		bit [3:0] flags_expected;
		bit [2:0] err_flags_expected;
		command_s cmd;

		cmd_f.try_get(cmd);
		emulate_alu(cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags, C_expected, flags_expected, err_flags_expected);
		if ((C_expected == t.C) && (flags_expected == t.flags) && (err_flags_expected == t.err_flags))begin
			$display("PASSED: B: %0h  A: %0h  op: %0b  err_flags: %0b  C: %0h  flags: %0b", cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags, t.C, t.flags);
			$display("EXPECTED: err_flags: %0b  C: %0h  flags: %0b \n", err_flags_expected, C_expected, flags_expected);
		end
		else begin
			$display("FAILED: B: %0h  A: %0h  op: %0b  err_flags: %0b  C: %0h  flags: %0b", cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags, t.C, t.flags);
			$display("EXPECTED: err_flags: %0b  C: %0h  flags: %0b \n", err_flags_expected, C_expected, flags_expected);
		end
	endfunction : write

	protected function void emulate_alu(
			input bit [31:0] B,
			input bit [31:0] A,
			input bit [2:0] op_bit,
			input bit [2:0] err_flags_in,
			output bit [31:0] C,
			output bit [3:0] flags,
			output bit [2:0] err_flags
			);
		reg cout;
		err_flags = err_flags_in;
		case(err_flags_in)
			default:
			begin
				C = 32'd0;
				flags = 4'b0000;
			end
			3'b000:
			begin
				case(op_bit)
					3'b000: {cout, C} = {1'b0, B} & {1'b0, A};
					3'b001: {cout, C} = {1'b0, B} | {1'b0, A};
					3'b100: {cout, C} = {1'b0, B} + {1'b0, A};
					3'b101: {cout, C} = {1'b0, B} - {1'b0, A};
					default: {cout, C} = {1'b0, 32'd0};
				endcase
				flags[3] = cout;
				flags[2] = (B[31]&&A[31]&&(!C[31]))||((!B[31])&&(!A[31])&&(C[31]));
				flags[1] = (C==0);
				flags[0] = C[31];
			end
		endcase
	endfunction

endclass : scoreboard

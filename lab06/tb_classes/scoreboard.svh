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

class scoreboard extends uvm_subscriber #(result_command);
    `uvm_component_utils(scoreboard)

	virtual mtm_Alu_bfm bfm;
	uvm_tlm_analysis_fifo #(sequence_item) cmd_f;
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function void build_phase(uvm_phase phase);
        cmd_f = new ("cmd_f", this);
    endfunction : build_phase

	function void write (result_command t);
		 string data_str;
		sequence_item cmd;
		result_command predicted;
		
		cmd_f.try_get(cmd);
		predicted = emulate_alu(cmd);
		
		data_str = {"\nSIN from DUT => ", cmd.convert2string(),"\n",
            "SOUT from DUT => " , t.convert2string(),"\n",
            "SOUT /Predicted => ",predicted.convert2string(), "\n"};
		
		if (!predicted.compare(t))
            `uvm_error("SELF CHECKER", {"FAIL: ",data_str})
        else
            `uvm_info ("SELF CHECKER", {"PASS: ", data_str}, UVM_HIGH)
		
//		if ((predicted.C == t.C) && (predicted.flags == t.flags) && (err_flags_expected == t.err_flags))begin
//			$display("PASSED: B: %0h  A: %0h  op: %0b  err_flags: %0b  C: %0h  flags: %0b", cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags, t.C, t.flags);
//			$display("EXPECTED: err_flags: %0b  C: %0h  flags: %0b \n", err_flags_expected, C_expected, flags_expected);
//		end
//		else begin
//			$display("FAILED: B: %0h  A: %0h  op: %0b  err_flags: %0b  C: %0h  flags: %0b", cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags, t.C, t.flags);
//			$display("EXPECTED: err_flags: %0b  C: %0h  flags: %0b \n", err_flags_expected, C_expected, flags_expected);
//		end
	endfunction : write

	function result_command emulate_alu(sequence_item cmd);
		bit cout;
		result_command predicted;
		predicted = new("predicted");
		
		predicted.err_flags = cmd.err_flags;
		case(cmd.err_flags)
			default:
			begin
				predicted.C = 32'd0;
				predicted.flags = 4'b0000;
			end
			3'b000:
			begin
				case(cmd.op)
					RST: {cout, predicted.C} = {1'b0, 32'd0};
					AND: {cout, predicted.C} = {1'b0, cmd.B} & {1'b0, cmd.A};
					OR: {cout, predicted.C} = {1'b0, cmd.B} | {1'b0, cmd.A};
					ADD: {cout, predicted.C} = {1'b0, cmd.B} + {1'b0, cmd.A};
					SUB: {cout, predicted.C} = {1'b0, cmd.B} - {1'b0, cmd.A};
					default: {cout, predicted.C} = {1'b0, 32'd0};
				endcase
				predicted.flags[3] = cout;
				//predicted.flags[2] = (cmd.B[31]&&cmd.A[31]&&(!predicted.C[31]))||((!cmd.B[31])&&(!cmd.A[31])&&(predicted.C[31]));
				predicted.flags[2] = 0;
				predicted.flags[1] = (predicted.C==0);
				predicted.flags[0] = predicted.C[31];
			end
		endcase
		return predicted;
	endfunction : emulate_alu

endclass : scoreboard

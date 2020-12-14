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

class scoreboard extends uvm_component;

	`uvm_component_utils(scoreboard)

	virtual mtm_Alu_bfm bfm;

	bit [31:0] B_queue[$];
	bit [31:0] A_queue[$];
	bit [2:0] op_queue[$];
	bit [2:0] err_flags_queue[$];
	
    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

	protected function void emulate_alu(
			input bit [31:0] B,
			input bit [31:0] A,
			input bit [2:0] op_bit,
			input bit [2:0] err_flags_in,
			output bit [31:0] C,
			output bit [3:0] flags,
			output bit [2:0] err_flags);

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

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1,"Failed to get BFM");
    endfunction : build_phase

	// odczytaj sin (initial + forever + read_serial_sin)
// -> i wkladam odczytane dane w SV fifo
	task run_phase(uvm_phase phase);
		forever begin
			bit [31:0] B;
			bit [31:0] A;
			bit [2:0] op_bit;
			bit [2:0] err_flags;

			bfm.read_serial_sin(B, A, op_bit, err_flags);

			B_queue.push_back(B);
			A_queue.push_back(A);
			op_queue.push_back(op_bit);
			err_flags_queue.push_back(err_flags);
		end

// odczytaj sout (initial + forever + read_serial_sout)
// sprawdz wynik i porownaj z ostatnim elementem fifo
		#70
		forever begin
			bit [31:0] B;
			bit [31:0] A;
			bit [2:0] op_bit;
			bit [2:0] err_flags_in;

			bit [31:0] C;
			bit [3:0] flags;
			bit [2:0] err_flags_out;

			bit [31:0] C_expected;
			bit [3:0] flags_expected;
			bit [2:0] err_flags_expected;

			bfm.read_serial_sout(C, flags, err_flags_out);

			B = B_queue.pop_front();
			A = A_queue.pop_front();
			op_bit = op_queue.pop_front();
			err_flags_in = err_flags_queue.pop_front();

			emulate_alu(B, A, op_bit, err_flags_in, C_expected, flags_expected, err_flags_expected);
			if ((C_expected == C) && (flags_expected == flags) && (err_flags_expected == err_flags_out))begin
				$display("PASSED: B: %0h  A: %0h  op: %0b  err_flags: %0b  C: %0h  flags: %0b", B, A, op_bit, err_flags_out, C, flags);
				$display("EXPECTED: err_flags: %0b  C: %0h  flags: %0b \n", err_flags_expected, C_expected, flags_expected);
			end
			else begin
				$display("FAILED: B: %0h  A: %0h  op: %0b  err_flags: %0b  C: %0h  flags: %0b", B, A, op_bit, err_flags_out, C, flags);
				$display("EXPECTED: err_flags: %0b  C: %0h  flags: %0b \n", err_flags_expected, C_expected, flags_expected);
			end
		end
	endtask : run_phase


endclass : scoreboard

/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 6:05:55 PM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

module mtm_Alu_tb();
//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------
	typedef enum bit[2:0] {
		AND = 3'b000,
		OR = 3'b001,
		ADD = 3'b100,
		SUB = 3'b101
	} op_t;

	typedef enum bit [1:0] {DATA, CTL, ERR} byte_type_t;
	typedef enum bit {BYTE_OK, BYTE_BAD} byte_status_t;

	bit [31:0] B_queue[$];
	bit [31:0] A_queue[$];
	op_t op_queue[$];

	bit [31:0] A;
	bit [31:0] B;
	bit [2:0] op_set_bit;
	op_t op_set;

	bit clk;
	bit rst_n;
	bit sin = 1;
	wire sout;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

	mtm_Alu u_mtm_Alu (
		.clk  (clk), //posedge active clock
		.rst_n(rst_n), //synchronous reset active low
		.sin  (sin), //serial data input
		.sout (sout) //serial data output
	);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------
	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint op_set {
			// #A1 test all operations
			bins A1_all_op[] = {[AND : SUB]};

			// #A2 test all operations after reset
			bins A2_rst_opn[] = (rst_n => [AND : SUB]);

			// #A3 test reset after all operations
			bins A3_opn_rst[] = ([AND : SUB] => rst_n);

			// #A6 two operations in row
			bins A4_twoops[] = ([AND : SUB] [* 2]);
		}
	endgroup

	covergroup zeros_or_ones_on_ops;

		option.name = "cg_zeros_or_ones_on_ops";

		all_ops : coverpoint op_set {
			ignore_bins null_ops = {rst_n};
		}

		a_leg: coverpoint A {
			bins zeros = {'h0000_0000};
			bins others= {['h0000_0001:'hFFFF_FFFE]};
			bins ones  = {'hFFFF_FFFF};
		}

		b_leg: coverpoint B {
			bins zeros = {'h0000_0000};
			bins others= {['h000_0001:'hFFFF_FFFE]};
			bins ones  = {'hFFFF_FFFF};
		}

		B_op_00_FF:  cross a_leg, b_leg, all_ops {

			// #B1 simulate all zero input for all the operations

			bins B1_add_00 = binsof (all_ops) intersect {ADD} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_and_00 = binsof (all_ops) intersect {AND} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_or_00 = binsof (all_ops) intersect {OR} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_sub_00 = binsof (all_ops) intersect {SUB} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 simulate all one input for all the operations

			bins B2_add_FF = binsof (all_ops) intersect {ADD} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_and_FF = binsof (all_ops) intersect {AND} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_or_FF = binsof (all_ops) intersect {OR} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_sub_FF = binsof (all_ops) intersect {SUB} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}
	endgroup

	op_cov oc;
	zeros_or_ones_on_ops c_00_FF;

	initial begin : coverage
		oc = new();
		c_00_FF = new();

		// instantiate covergroups
		forever begin : sample_cov
			read_serial_sin(A, B, op_set_bit);
			assign op_set = op_set_bit;
			@(negedge clk);
			oc.sample();
			c_00_FF.sample();
		end

	end

	task automatic read_serial_sout(
			output bit [31:0] C,
			output bit [3:0] flags
		);
		byte_type_t bt;
		bit [7:0] d;
		bit [2:0] crc;
		bit parity;

		read_byte_sout(bt, d);
		C[31:24] = d;
		read_byte_sout(bt, d);
		C[23:16] = d;
		read_byte_sout(bt, d);
		C[15:8] = d;
		read_byte_sout(bt, d);
		C[7:0] = d;

		read_byte_sout(bt, d);
		flags = d[6:3];
		crc = d[2:0];
	endtask

	task automatic read_byte_sout(
			output byte_type_t bt,
			output bit [7:0] d);

		//START BIT
		while(sout == 1) @(negedge clk);
		//@(negedge clk);
		// Second bit defines byte type
		@(negedge clk);
		if(sout == 0) begin : read_data_byte
			bt = DATA;
			for(int i = 7; i>=0; i--) begin
				@(negedge clk) d[i] = sout;
			end
		end
		else begin : read_ctl_byte
			bt = CTL;
			for(int i = 7; i>=0; i--) begin
				@(negedge clk) d[i] = sout;
			end
		end
		@(negedge clk);
	endtask

	task automatic read_serial_sin(
			output bit [31:0] B,
			output bit [31:0] A,
			output bit [2:0] op
		);
		byte_type_t bt;
		bit [7:0] d;
		bit [2:0] op_bit;
		bit [3:0] crc;
		// LOOP or
		read_byte_sin(bt, d);
		B[31:24] = d;
		read_byte_sin(bt, d);
		B[23:16] = d;
		read_byte_sin(bt, d);
		B[15:8] = d;
		read_byte_sin(bt, d);
		B[7:0] = d;

		read_byte_sin(bt, d);
		A[31:24] = d;
		read_byte_sin(bt, d);
		A[23:16] = d;
		read_byte_sin(bt, d);
		A[15:8] = d;
		read_byte_sin(bt, d);
		A[7:0] = d;

		read_byte_sin(bt, d);
		op = d[6:4];
		//$cast(op, op_bit);
		crc = d[3:0];
	endtask

	task automatic read_byte_sin(
			output byte_type_t bt,
			output bit [7:0] d);

		//START BIT
		while(sin == 1) @(negedge clk);
		//@(negedge clk);
		// Second bit defines byte type
		@(negedge clk);
		if(sin == 0) begin : read_data_byte
			bt = DATA;
			for(int i = 7; i>=0; i--) begin
				@(negedge clk) d[i] = sin;
			end
		end
		else begin : read_ctl_byte
			bt = CTL;
			for(int i = 7; i>=0; i--) begin
				@(negedge clk) d[i] = sin;
			end
		end
		@(negedge clk);
	endtask

	function [3:0] crc4_generate(
			input bit [31:0] B,
			input bit [31:0] A,
			input bit [2:0] op_bit);
		bit [71:0] crc_data;
		bit [3:0] reminder;

		begin
			crc_data = {B, A, {1'b1, op_bit, 4'b0000}};
			reminder = 0;
			repeat(72)
			begin
				reminder = {reminder[2], reminder[1], reminder[3]^reminder[0], reminder[3]^crc_data[71]};
				crc_data = {crc_data[70:0], 1'b0};
			end
			crc4_generate = reminder;
		end
	endfunction

	function bit [2:0] crc3_generate(
			input bit [31:0] C,
			input bit [3:0] flags);
		bit [39:0] crc_data;
		bit [2:0] reminder;
		begin
			crc_data = {C, {1'b0, flags, 3'b000}};
			reminder = 0;
			repeat(40)
			begin
				reminder = {reminder[1], reminder[2]^reminder[0], reminder[2]^crc_data[39]};
				crc_data = {crc_data[38:0], 1'b0};
			end
			crc3_generate = reminder;
		end
	endfunction
//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clock_generator
		clk = 0;
		forever #5 clk = ~clk;
	end
//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------
//---------------------------------
// Random data generation functions
//---------------------------------
	function bit [31:0] get_data();
		bit [2:0] zero_ones;
		zero_ones = $random;
		if (zero_ones == 3'b000)
			return 32'h0000_0000;
		else if (zero_ones == 3'b111)
			return 32'hFFFF_FFFF;
		else
			return $random;
	endfunction : get_data

	function op_t get_op();
		bit [1:0] op_choice;
		op_choice = $random;
		case (op_choice)
			2'b00 : return AND;
			2'b01 : return OR;
			2'b10 : return ADD;
			2'b11 : return SUB;
		endcase // case (op_choice)
	endfunction : get_op

	initial begin : tester
		bit [31:0] B;
		bit [31:0] A;
		op_t op;

		#20 rst_n = '1;
		#30;

		repeat (500) begin : tester_main
			B = get_data();
			A = get_data();
			op = get_op();
			send_cmd(B, A, op);
		end

		#2000 rst_n = '1;
		#30 $finish;
	end

	task send_cmd(
			input bit [31:0] B,
			input bit [31:0] A,
			input op_t op
		);
		bit [2:0] op_bit;
		$cast(op_bit, op);
		send_data_byte(B[31:24]);
		send_data_byte(B[23:16]);
		send_data_byte(B[15:8]);
		send_data_byte(B[7:0]);
		send_data_byte(A[31:24]);
		send_data_byte(A[23:16]);
		send_data_byte(A[15:8]);
		send_data_byte(A[7:0]);
		send_ctl_byte({1'b0, op, crc4_generate(B, A, op)});
	endtask

	task send_data_byte(input bit [7:0] d);
		send_byte({2'b00, d, 1'b1});
	endtask

	task send_ctl_byte(input bit [7:0] d);
		send_byte({2'b01, d, 1'b1});
	endtask

	task send_byte(input bit[10:0] d);
		for(int i=10; i>=0; i--)begin
			@(negedge clk) sin = d[i];
		end
	endtask
//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

// odczytaj sin (initial + forever + read_serial_sin)
// -> i wkladam odczytane dane w SV fifo
	initial begin
		forever begin
			bit [31:0] B;
			bit [31:0] A;
			bit [2:0] op_bit;
			op_t op;
			read_serial_sin(B, A, op_bit);
			assign op = op_bit;
			B_queue.push_back(B);
			A_queue.push_back(A);
			op_queue.push_back(op);
		end
	end

// odczytaj sout (initial + forever + read_serial_sout)
// sprawdz wynik i porównaj z ostatnim elementem fifo
	initial
	begin
		#70
		forever begin
			bit [31:0] C;
			bit [3:0] flags;

			bit [31:0] C_expected;
			bit [3:0] flags_expected;

			bit [31:0] B;
			bit [31:0] A;
			op_t op;

			read_serial_sout(C, flags);

			B = B_queue.pop_front();
			A = A_queue.pop_front();
			op = op_queue.pop_front();

			emulate_alu(B, A, op, C_expected, flags_expected);
			if ((C_expected == C) && (flags_expected == flags))begin
				$display("PASSED: B: %0h  A: %0h op: %s C: %0h", B, A, op.name(), C);
			end
			else begin
				$display("FAILED: B: %0h  A: %0h op: %s C: %0h", B, A, op.name(), C);
			end
		end
	end

	function void emulate_alu(
			input bit [31:0] B,
			input bit [31:0] A,
			input op_t op,
			output bit [31:0] C,
			output bit [3:0] flags);

		reg cout;
		begin
			case(op)
				AND: {cout, C} = {1'b0, B} & {1'b0, A};
				OR: {cout, C} = {1'b0, B} | {1'b0, A};
				ADD: {cout, C} = {1'b0, B} + {1'b0, A};
				SUB: {cout, C} = {1'b0, B} - {1'b0, A};
			//default: {cout, C} = {1'b0, C};
			endcase
			flags[3] = cout;
			flags[2] = (B[31]&&A[31]&&(!C[31]))||((!B[31])&&(!A[31])&&(C[31]));
			flags[1] = (C==0);
			flags[0] = C[31];
		end
	endfunction

endmodule
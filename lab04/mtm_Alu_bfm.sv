interface mtm_Alu_bfm;
	import mtm_Alu_pkg::*;
	bit clk;
	bit rst_n;
	bit sin = 1;
	wire sout;

	task reset_alu();
		rst_n = 1'b0;
		@(negedge clk);
		@(negedge clk);
		rst_n = 1'b1;
	endtask : reset_alu

	task automatic read_serial_sout(
			output bit [31:0] C,
			output bit [3:0] flags,
			output bit [2:0] err_flags
		);
		byte_type_t bt;
		bit [7:0] d;
		bit [2:0] crc;
		//bit parity;

		read_byte_sout(bt, d);
		if((bt == DATA) || (bt == CTL)) begin
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
			err_flags = 3'b000;
		end
		else begin
			C[31:0] = 32'd0;
			err_flags = d[6:4];
			flags = 4'b0000;
			crc = 3'b000;
		end
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
			@(negedge clk);
			d[7] = sout;
			if(sout == 0) begin
				bt = CTL;
				for(int i = 6; i>=0; i--) begin
					@(negedge clk) d[i] = sout;
				end
			end
			else begin
				bt = ERR;
				for(int i = 6; i>=0; i--) begin
					@(negedge clk) d[i] = sout;
				end
			end
		end
		@(negedge clk);
	endtask

	task automatic read_serial_sin(
			output bit [31:0] B,
			output bit [31:0] A,
			output bit [2:0] op_bit,
			output bit [2:0] err_flags
		);
		byte_type_t bt;
		bit [7:0] d;
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
		op_bit = d[6:4];
		crc = d[3:0];
		if(bt == DATA) begin
			err_flags = 3'b100;
		end
		else if (crc != crc4_generate(B, A, op_bit)) begin
			err_flags = 3'b010;
		end
		else if (d[5] == 1'b1) begin
			err_flags = 3'b001;
		end

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

	initial begin : clock_generator
		clk = 0;
		forever #5 clk = ~clk;
	end

	task send_cmd(
			input bit [31:0] B,
			input bit [31:0] A,
			input bit [2:0] op_bit,
			input bit [2:0] err_flags
		);
		if(op_bit == 3'b111)
		reset_alu();	
		else
		case(err_flags)
			default: begin
				send_data_byte(B[31:24]);
				send_data_byte(B[23:16]);
				send_data_byte(B[15:8]);
				send_data_byte(B[7:0]);
				send_data_byte(A[31:24]);
				send_data_byte(A[23:16]);
				send_data_byte(A[15:8]);
				send_data_byte(A[7:0]);
				send_ctl_byte({1'b0, op_bit, crc4_generate(B, A, op_bit)});
			end
			3'b100: begin
				send_data_byte(B[31:24]);
				send_data_byte(B[23:16]);
				send_data_byte(B[15:8]);
				send_data_byte(B[7:0]);
				send_data_byte(A[31:24]);
				send_data_byte(A[23:16]);
				send_data_byte(A[15:8]);
				send_data_byte(A[7:0]);
				send_data_byte(A[7:0]);
			end
			3'b010: begin
				send_data_byte(B[31:24]);
				send_data_byte(B[23:16]);
				send_data_byte(B[15:8]);
				send_data_byte(B[7:0]);
				send_data_byte(A[31:24]);
				send_data_byte(A[23:16]);
				send_data_byte(A[15:8]);
				send_data_byte(A[7:0]);
				send_ctl_byte({1'b0, op_bit, (crc4_generate(B, A, op_bit)+1)});
			end
			3'b001: begin
				send_data_byte(B[31:24]);
				send_data_byte(B[23:16]);
				send_data_byte(B[15:8]);
				send_data_byte(B[7:0]);
				send_data_byte(A[31:24]);
				send_data_byte(A[23:16]);
				send_data_byte(A[15:8]);
				send_data_byte(A[7:0]);
				send_ctl_byte({1'b0, 3'b010, crc4_generate(B, A, op_bit)});
			end
		endcase
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

	command_monitor command_monitor_h;

	initial begin : command_monitor_thread
		bit [31:0] B;
		bit [31:0] A;
		bit [2:0] op_bit;
		bit [2:0] err_flags;
		command_s command;
		forever begin
			read_serial_sin(B,A,op_bit,err_flags);
			command.B = B;
			command.A = A;
			command.op_set_bit = op_bit;
			command.err_flags = err_flags;
			command_monitor_h.write_to_monitor(command);
		end
	end : command_monitor_thread

	result_monitor result_monitor_h;

	initial begin : result_monitor_thread
		result_s result;
		#70
		forever begin
			read_serial_sout(result.C, result.flags, result.err_flags);
			result_monitor_h.write_to_monitor(result);
		end
	end : result_monitor_thread

endinterface : mtm_Alu_bfm


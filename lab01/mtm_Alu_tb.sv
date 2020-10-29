/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 9:47:03 PM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

module mtm_Alu_tb();
	
//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

	localparam 	DATA_TYPE = 1'b0,
	           	CMD_TYPE = 1'b1;
				
	localparam 	AND = 3'b000,
	           	OR = 3'b001,
				ADD = 3'b100,
				SUB = 3'b101;

	logic clk; 
	logic rst_n = 1;
	bit finish_simulation = 0;

	logic sin = 1;
	wire sout;
	
   	logic [31:0] A = 0;
    logic [31:0] B = 0;	

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

    mtm_Alu DUT(
        .clk(clk),
        .rst_n(rst_n),
        .sin(sin),
        .sout(sout)
    );

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

	initial begin : clk_gen
		clk = 0;
		forever begin : clk_frv
			#10;
			clk = ~clk;
		end
	end
	
//------------------------------------------------------------------------------
// Macros/Tasks/Functions	
//------------------------------------------------------------------------------

	task drive_reset;
	begin
		@(negedge clk);
		rst_n <= 0;
		repeat (10) @(negedge clk);
		rst_n <= 1;
		repeat (10) @(negedge clk);
	end
	endtask
	
	task send_byte(input frame_type, input [7:0] essence);
	begin
		@(negedge clk)
		sin <= 1'b0;
		@(negedge clk)
		sin <= frame_type;
		@(negedge clk)
		sin = essence[7];
        @(negedge clk)
        sin = essence[6];
        @(negedge clk)
        sin = essence[5];
        @(negedge clk)
        sin = essence[4];
        @(negedge clk)
        sin = essence[3];
        @(negedge clk)
        sin = essence[2];
        @(negedge clk)
        sin = essence[1];
        @(negedge clk)
        sin = essence[0];
        @(negedge clk)
		sin <= 1'b1;
		@(negedge clk);	
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
		@(negedge clk);
	end
	endtask

	task send_calculation_data (input [31:0] B, input [31:0] A, input [2:0] OP, input [3:0] CRC);
	begin
		send_byte(DATA_TYPE, B[31:24]);
		send_byte(DATA_TYPE, B[23:16]);
		send_byte(DATA_TYPE, B[15:8]);
		send_byte(DATA_TYPE, B[7:0]);
		
		send_byte(DATA_TYPE, A[31:24]);
		send_byte(DATA_TYPE, A[23:16]);
		send_byte(DATA_TYPE, A[15:8]);
		send_byte(DATA_TYPE, A[7:0]);		
	
		send_byte(CMD_TYPE, {1'b1, OP, CRC});
	end	
	endtask
	
	function [3:0] crc4_generate;
	input [31:0] B;
	input [31:0] A;
	input [2:0] OP;
	reg [71:0] crc_data;
	reg [3:0] reminder;
	   begin
	       crc_data = {B, A, {1'b1, OP, 4'b0000}};
	       reminder = 0;
	       repeat(72)
	       begin
	           reminder = {reminder[2], reminder[1], reminder[3]^reminder[0], reminder[3]^crc_data[71]};
	           crc_data = {crc_data[70:0], 1'b0};
	       end
	       crc4_generate = reminder;
	   end
	endfunction
	
	initial
	begin
		drive_reset;
		
		B = 32'h33333333;
		A = 32'h33333333;
		send_calculation_data(B, A, ADD, crc4_generate(B, A, ADD));
		repeat (30) @(negedge clk);
		
		B = 32'h12121212;
		A = 32'h12121212;
		send_calculation_data(B, A, ADD, crc4_generate(B, A, ADD));
		repeat (30) @(negedge clk);
		
		repeat (100) @(negedge clk);
		finish_simulation <= 1'b1;
        $finish;		
	end

endmodule
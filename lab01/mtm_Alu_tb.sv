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
	
typedef enum bit [1:0] {DATA, CTL, ERR} byte_t;
//	typedef enum bit {BYTE_OK, BYTE_BAD}
	
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
initial begin : tester
	bit [31:0] A;
	bit [31:0] B;
	op_t op;
	
	#20 rst_n = '1;
	#30;
	
	//LOOP ...
	// A =
	// B =
	// op =
	send_cmd(A, B, op);
	// ... END LOOP
	
	#2000 $finish;
end

task send_cmd(
	input bit [31:0] A,
	input bit [31:0] B,
	input op_t op
	);
	bit [2:0] op_bit;
	bit [3:0] crc;
	$cast(op_bit, op);
	send_data_byte(B[31:24]);
	send_data_byte(B[23:16]);
	send_data_byte(B[15:8]);
	send_data_byte(B[7:0]);
	send_data_byte(A[31:24]);
	send_data_byte(A[23:16]);
	send_data_byte(A[15:8]);
	send_data_byte(A[7:0]);
	send_ctl_byte({1'b0, op_bit, crc});
	
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
	
endmodule

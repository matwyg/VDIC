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
typedef enum bit {PROCESS_OK, PROCESS_BAD} process_status_t;
	
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
//initial begin : coverage
	//bit [31:0] A;
//	bit [31:0] B;
//	bit [31:0] C;
//	op_t op;
//	process_status_t ps;
//	bit [3:0] flags;
//	bit [5:0] err_flags;
	
	// instantiate covergroups
//	forever begin
//		read_serial_sin(ps, A, B, op);
		// sample covergroup;
//		end
	
//end

task read_serial_sin(
	output process_status_t ps,
	output bit [31:0] B,
	output bit [31:0] A,
	output op_t op
	);
	byte_type_t bt;
	byte_status_t bs;
	bit [7:0] d;
	bit [2:0] op_bit;
	bit [3:0] crc;
	bit [3:0] calculated_crc;
	// LOOP or
	for(int i = 3; i>=0; i--)begin
		read_byte(bs, bt, d);
		B[31:24] = d;
		B = B>>8;
		ps = ((bs == BYTE_OK) && (bt == DATA)) ? PROCESS_OK : PROCESS_BAD; 
	end
	for(int i = 3; i>=0; i--)begin
		read_byte(bs, bt, d);
		A[31:24] = d;
		A = A>>8;
		ps = ((ps == PROCESS_OK) && (bs == BYTE_OK) && (bt == DATA)) ? PROCESS_OK : PROCESS_BAD; 
	end
	read_byte(bs, bt, d);
	op_bit = d[6:4];
	$cast(op, op_bit);
	crc = d[3:0];
	calculated_crc = crc4_generate(B, A, op_bit);
	ps = ((ps == PROCESS_OK) && (bs == BYTE_OK) && (bt == CTL) && (crc == calculated_crc)) ? PROCESS_OK : PROCESS_BAD; 
endtask

task read_byte(
		output byte_status_t bs,
		output byte_type_t bt,
		output bit [7:0] d);
	
	//START BIT
	while(sin != 0) @(negedge clk);
	
	// Second bit defines byte type
	@(negedge clk)
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
	@(negedge clk)
	if(sin == 1) begin : read_stop_bit
		bs = BYTE_OK;
	end
	else begin
		bs = BYTE_BAD;
	end
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
	bit [31:0] B;
	bit [31:0] A;
	op_t op;
	
	#20 rst_n = '1;
	#30;
	
	//LOOP ...
	// A =
	// B =
	// op =
	B = 32'h33333333;
	A = 32'h33333333;
	op = ADD;
	send_cmd(B, A, op);
	// ... END LOOP
	
	#2000 $finish;
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
	send_ctl_byte({1'b0, op_bit, crc4_generate(B, A, op_bit)});
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

// odczytaj sout (initial + forever + read_serial_sout)
// sprawdz wynik i porównaj z ostatnim elementem fifo
	
endmodule

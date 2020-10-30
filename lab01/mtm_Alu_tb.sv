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

//	bit [3:0] flags;
//	bit [5:0] err_flags;
	
	// instantiate covergroups
//	forever begin
//		read_serial_sin(A, B, op);
		// sample covergroup;
//		end
	
//end

task read_serial_sout(
	output byte_type_t bt,
	output bit [31:0] C,
	output bit [3:0] flags,
	output bit [5:0] err_flags
	);
	bit [7:0] d;
	bit [2:0] crc;
	bit parity;
	
	read_byte(bt, d);
	if(bt == DATA) begin
		for(int i = 3; i>=0; i--)begin
			read_byte(bt, d);
			C[31:24] = d;
			C = C>>8;
		end
	end 
	else if (d[7] == 1'b0) begin
		flags = d[6:3];
		crc = d[2:0];
		bt = DATA;
	end
	else begin
		err_flags = d[6:1];
		parity = d[0];
		bt = ERR;
	end
endtask

task read_serial_sin(
	output bit [31:0] B,
	output bit [31:0] A,
	output op_t op
	);
	byte_type_t bt;
	bit [7:0] d;
	bit [2:0] op_bit;
	bit [3:0] crc;
	// LOOP or
	for(int i = 3; i>=0; i--)begin
		read_byte(bt, d);
		B[31:24] = d;
		B = B>>8;
	end
	for(int i = 3; i>=0; i--)begin
		read_byte(bt, d);
		A[31:24] = d;
		A = A>>8; 
	end
	read_byte(bt, d);
	op_bit = d[6:4];
	$cast(op, op_bit);
	crc = d[3:0];
endtask

task read_byte(
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
      bit [3:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 4'b0000)
        return 32'h0000_0000;
      else if (zero_ones == 4'b1111)
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
	
	repeat (5) begin : tester_main
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

// odczytaj sout (initial + forever + read_serial_sout)
// sprawdz wynik i porównaj z ostatnim elementem fifo
	
endmodule

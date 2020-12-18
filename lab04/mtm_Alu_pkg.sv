`timescale 1ns/1ps

package mtm_Alu_pkg;
   import uvm_pkg::*;
`include "uvm_macros.svh"

	typedef enum bit[2:0] {
		AND = 3'b000,
		OR = 3'b001,
		ADD = 3'b100,
		SUB = 3'b101
	} op_t;

	typedef enum bit [1:0] {DATA, CTL, ERR} byte_type_t;
	typedef enum bit {BYTE_OK, BYTE_BAD} byte_status_t;

	typedef struct packed {
		bit [31:0] A;
		bit [31:0] B;
		bit [2:0] op_set_bit;
		bit [2:0] err_flags;
	} command_s;

	typedef struct packed {
		bit [31:0] C;
		bit [3:0] flags;
		bit [2:0] err_flags;
	} result_s;


`include "coverage.svh"
`include "base_tester.svh"
`include "random_tester.svh"
`include "min_max_tester.svh"   
`include "scoreboard.svh"
`include "driver.svh"
`include "command_monitor.svh"
`include "result_monitor.svh"
`include "env.svh"
`include "random_test.svh"
`include "min_max_test.svh"

endpackage : mtm_Alu_pkg

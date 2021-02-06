/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 11:49:26 PM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

module top;
	import uvm_pkg::*;
`include "uvm_macros.svh"
	import mtm_Alu_pkg::*;
//`include "mtm_Alu_macros.svh"

	mtm_Alu_bfm class_bfm();

	mtm_Alu class_dut_mtm_Alu (
		.clk  (class_bfm.clk), //posedge active clock
		.rst_n(class_bfm.rst_n), //synchronous reset active low
		.sin  (class_bfm.sin), //serial data input
		.sout (class_bfm.sout) //serial data output
	);

	mtm_Alu_bfm module_bfm();

	mtm_Alu module_dut_mtm_Alu (
		.clk  (module_bfm.clk), //posedge active clock
		.rst_n(module_bfm.rst_n), //synchronous reset active low
		.sin  (module_bfm.sin), //serial data input
		.sout (module_bfm.sout) //serial data output
		);
		
	mtm_Alu_tester_module stim_module(module_bfm);

	initial begin
		uvm_config_db #(virtual mtm_Alu_bfm)::set(null, "*", "class_bfm", class_bfm);
		uvm_config_db #(virtual mtm_Alu_bfm)::set(null, "*", "module_bfm", module_bfm);
		run_test("dual_test");
	end

endmodule : top


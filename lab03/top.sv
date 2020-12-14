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
`include "mtm_Alu_macros.svh"

mtm_Alu_bfm bfm();

mtm_Alu DUT (
	.clk  (bfm.clk), //posedge active clock
	.rst_n(bfm.rst_n), //synchronous reset active low
	.sin  (bfm.sin), //serial data input
	.sout (bfm.sout) //serial data output
	);

initial begin
    uvm_config_db #(virtual mtm_Alu_bfm)::set(null, "*", "bfm", bfm);
    run_test();
end
		
endmodule : top


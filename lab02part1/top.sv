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
	mtm_Alu_bfm bfm();
	tester tester_i (bfm);
	coverage coverage_i (bfm);
	scoreboard scoreboard_i (bfm);
	
	mtm_Alu DUT (
		.clk  (bfm.clk), //posedge active clock
		.rst_n(bfm.rst_n), //synchronous reset active low
		.sin  (bfm.sin), //serial data input
		.sout (bfm.sout) //serial data output
	);
		
endmodule

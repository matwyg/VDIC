/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 3:10:43 PM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

module counter_tb();

	wire clk;
	wire reset;
	wire enable;
	wire [3:0] q;

	counter u_counter (
		.clk   (clk),
		.enable(enable),
		.q     (q),
		.reset (reset)
	);

endmodule

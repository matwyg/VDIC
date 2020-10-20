/******************************************************************************
 * (C) Copyright 2013 <Company Name> All Rights Reserved
 *
 * MODULE:    name
 * DEVICE:
 * PROJECT:
 * AUTHOR:    mwygrzywalski
 * DATE:      2020 3:03:46 PM
 *
 * ABSTRACT:  You can customize the file content from Window -> Preferences -> DVT -> Code Templates -> "verilog File"
 *
 *******************************************************************************/

module counter(
		input wire clk,
		input wire reset,
		input wire enable,
		output reg [3:0] q
	);

	always @(posedge clk) begin
		if(reset)
			q <= 0;
		else
			if(enable)
				q <= q + 1;
	end

endmodule

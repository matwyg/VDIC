class min_max_tester extends random_tester;

    `uvm_component_utils(min_max_tester)

    function [31:0] get_data();
        bit [1:0] op_choice;
		op_choice = $random;
		case (op_choice) 
			2'b00 : return 32'd0;
			2'b01 : return 32'hFFFF_FFFF;
			2'b10 : return 32'd0;
			2'b11 : return 32'hFFFF_FFFF;
		endcase // case (op_choice)
	endfunction : get_data

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : min_max_tester
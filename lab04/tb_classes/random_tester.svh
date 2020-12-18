class random_tester extends base_tester;
    
    `uvm_component_utils (random_tester)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

    function op_t get_op();
		bit [2:0] op_choice;
		op_choice = $random;
		case (op_choice)
			3'b000 : return AND;
			3'b001 : return OR;
			3'b010 : return ADD;
			3'b011 : return SUB;
			3'b100 : return AND;
			3'b101 : return OR;
			3'b110 : return ADD;
			3'b111 : return SUB;
		endcase // case (op_choice)
	endfunction : get_op

	function [31:0] get_data();
		return $random;
	endfunction : get_data

	function [2:0] get_err_flags();
		bit [2:0] err_choice;
		err_choice = $random;
		case (err_choice)
			3'b000 : return 3'b001;
			3'b001 : return 3'b010;
			3'b010 : return 3'b100;
			default : return 3'b000;
		endcase
	endfunction : get_err_flags

endclass : random_tester
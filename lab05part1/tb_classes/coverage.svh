class coverage extends uvm_subscriber #(random_command);
    `uvm_component_utils(coverage)

	protected bit [31:0] A;
	protected bit [31:0] B;
	protected bit [2:0] err_flags;
	protected op_t op_set;
	

	covergroup op_cov;

		option.name = "cg_op_cov";

		coverpoint op_set {
			// #A1 test all operations
			bins A1_all_op[] = {[AND : SUB]};

			// #A2 two operations in row
			bins A2_twoops[] = ([AND : SUB] [* 2]);
		}
	endgroup

	covergroup zeros_or_ones_on_ops;

		option.name = "cg_zeros_or_ones_on_ops";

		all_ops : coverpoint op_set {
			bins A1_all_op[] = {[AND : SUB]};
		}

		a_leg: coverpoint A {
			bins zeros = {'h0000_0000};
			bins others= {['h0000_0001:'hFFFF_FFFE]};
			bins ones  = {'hFFFF_FFFF};
		}

		b_leg: coverpoint B {
			bins zeros = {'h0000_0000};
			bins others= {['h000_0001:'hFFFF_FFFE]};
			bins ones  = {'hFFFF_FFFF};
		}

		B_op_00_FF:  cross a_leg, b_leg, all_ops {

			// #B1 simulate all zero input for all the operations

			bins B1_add_00 = binsof (all_ops) intersect {ADD} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_and_00 = binsof (all_ops) intersect {AND} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_or_00 = binsof (all_ops) intersect {OR} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			bins B1_sub_00 = binsof (all_ops) intersect {SUB} &&
			(binsof (a_leg.zeros) || binsof (b_leg.zeros));

			// #B2 simulate all one input for all the operations

			bins B2_add_FF = binsof (all_ops) intersect {ADD} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_and_FF = binsof (all_ops) intersect {AND} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_or_FF = binsof (all_ops) intersect {OR} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			bins B2_sub_FF = binsof (all_ops) intersect {SUB} &&
			(binsof (a_leg.ones) || binsof (b_leg.ones));

			ignore_bins others_only =
			binsof(a_leg.others) && binsof(b_leg.others);
		}
	endgroup

	covergroup err_resp;

		option.name = "cg_err_resp";

		coverpoint err_flags {
			// #A1 test all operations
			bins data_err = {3'b100};
			bins crc_err = {3'b010};
		//bins op_err = {3'b001};
		}
	endgroup

	function new (string name, uvm_component parent);
        super.new(name, parent);
        op_cov               = new();
        zeros_or_ones_on_ops = new();
		err_resp = new();
    endfunction : new

    function void write(random_command t);
        A      = t.A;
        B      = t.B;
        op_set = t.op;
		err_flags = t.err_flags;
		op_cov.sample();
		zeros_or_ones_on_ops.sample();
		err_resp.sample();
    endfunction : write

    // function void build_phase(uvm_phase phase);
    //     if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
    //         $fatal(1,"Failed to get BFM");
    // endfunction : build_phase

	// task run_phase(uvm_phase phase);
	// 	bit [31:0] cast_ok;
	// 	forever begin : sampling_block
	// 		bfm.read_serial_sin(A, B, op_set_bit, err_flags);
	// 		cast_ok = $cast(op_set, op_set_bit);
	// 		@(negedge bfm.clk);
	// 		op_cov.sample();
	// 		zeros_or_ones_on_ops.sample();
	// 		err_resp.sample();
	// 	end : sampling_block
	// endtask : run_phase

endclass : coverage

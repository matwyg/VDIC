class command_monitor extends uvm_component;
    `uvm_component_utils(command_monitor)

    uvm_analysis_port #(command_s) ap;

    function void build_phase(uvm_phase phase);
        virtual mtm_Alu_bfm bfm;

        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");

        bfm.command_monitor_h = this;

        ap = new("ap",this);

    endfunction : build_phase

    function void write_to_monitor(command_s cmd);
    //   $display("COMMAND MONITOR: B: %0h  A: %0h  op: %0b  err_flags: %0b", cmd.B, cmd.A, cmd.op_set_bit, cmd.err_flags);
        ap.write(cmd);
    endfunction : write_to_monitor

    function new (string name, uvm_component parent);
        super.new(name,parent);
    endfunction

endclass : command_monitor
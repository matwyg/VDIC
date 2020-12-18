class driver extends uvm_component;
    `uvm_component_utils(driver)

    virtual mtm_Alu_bfm bfm;
    uvm_get_port #(command_s) command_port;

    function void build_phase(uvm_phase phase);
        if(!uvm_config_db #(virtual mtm_Alu_bfm)::get(null, "*","bfm", bfm))
            $fatal(1, "Failed to get BFM");
        command_port = new("command_port",this);
    endfunction : build_phase

    task run_phase(uvm_phase phase);
        command_s command;
        result_s result;

        forever begin : command_loop
            command_port.get(command);
            bfm.send_cmd(command.B, command.A, command.op_set_bit, command.err_flags);
        end : command_loop
    endtask : run_phase

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction : new

endclass : driver


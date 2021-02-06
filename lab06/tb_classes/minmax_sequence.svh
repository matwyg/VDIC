class minmax_sequence extends uvm_sequence #(sequence_item);
    `uvm_object_utils(minmax_sequence)

    sequence_item command;

    function new(string name = "minmax_sequence");
        super.new(name);
    endfunction : new
    
    task body();
        `uvm_info("SEQ_MINMAX","",UVM_MEDIUM)
        `uvm_do_with(command, {command.op == RST;});
	    
        repeat (200) begin
            `uvm_do_with(command, {A inside {32'h0000_0000, 32'hFFFF_FFFF}; B inside {32'h0000_0000, 32'hFFFF_FFFF}; op != RST;});
        end
    endtask : body
endclass : minmax_sequence

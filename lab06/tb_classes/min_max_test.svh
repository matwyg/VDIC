class min_max_test extends mtm_Alu_base_test;
   `uvm_component_utils(min_max_test)

   task run_phase(uvm_phase phase);
      minmax_sequence minmax;
      minmax = new("minmax");

      phase.raise_objection(this);
      minmax.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase
      
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass

class random_test extends mtm_Alu_base_test;
   `uvm_component_utils(random_test)


   task run_phase(uvm_phase phase);
      random_sequence random;
      random = new("random");

      phase.raise_objection(this);
      random.start(sequencer_h);
      phase.drop_objection(this);
   endtask : run_phase
      
      
   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction : new

endclass
/*
   Copyright 2013 Ray Salemi

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/
module top;

//------------------------------------------------------------------------------
// type and variable definitions
//------------------------------------------------------------------------------

   typedef enum bit[2:0] {no_op  = 3'b000,
                          add_op = 3'b001, 
                          and_op = 3'b010,
                          xor_op = 3'b011,
                          mul_op = 3'b100,
                          rst_op = 3'b111} operation_t;
   bit [7:0]    A;
   bit [7:0]    B; 
   bit          clk;
   bit          reset_n;
   wire [2:0]   op;
   bit          start;
   wire         done;
   wire [15:0]  result;
   operation_t  op_set;

   assign op = op_set;

//------------------------------------------------------------------------------
// DUT instantiation
//------------------------------------------------------------------------------

   tinyalu DUT (.A, .B, .clk, .op, .reset_n, .start, .done, .result);

//------------------------------------------------------------------------------
// Coverage block
//------------------------------------------------------------------------------

   covergroup op_cov;

      option.name = "cg_op_cov";

      coverpoint op_set {
         // #A1 test all operations
         bins A1_single_cycle[] = {[add_op : xor_op], rst_op,no_op};
         bins A1_multi_cycle = {mul_op};

         // #A2 test all operations after reset
         bins A2_rst_opn[] = (rst_op => [add_op:mul_op]);

         // #A3 test reset after all operations
         bins A3_opn_rst[] = ([add_op:mul_op] => rst_op);

         // #A4 multiply after single-cycle operation
         bins A4_sngl_mul[] = ([add_op:xor_op],no_op => mul_op);

         // #A5 single-cycle operation after multiply
         bins A5_mul_sngl[] = (mul_op => [add_op:xor_op], no_op);

         // #A6 two operations in row
         bins A6_twoops[] = ([add_op:mul_op] [* 2]);

         // bins manymult = (mul_op [* 3:5]);
      }

   endgroup

   covergroup zeros_or_ones_on_ops;

      option.name = "cg_zeros_or_ones_on_ops";

      all_ops : coverpoint op_set {
         ignore_bins null_ops = {rst_op, no_op};
      }

      a_leg: coverpoint A {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }

      b_leg: coverpoint B {
         bins zeros = {'h00};
         bins others= {['h01:'hFE]};
         bins ones  = {'hFF};
      }

      B_op_00_FF:  cross a_leg, b_leg, all_ops {

         // #B1 simulate all zero input for all the operations

         bins B1_add_00 = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_and_00 = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_xor_00 = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         bins B1_mul_00 = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.zeros) || binsof (b_leg.zeros));

         // #B2 simulate all one input for all the operations

         bins B2_add_FF = binsof (all_ops) intersect {add_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_and_FF = binsof (all_ops) intersect {and_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_xor_FF = binsof (all_ops) intersect {xor_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_mul_FF = binsof (all_ops) intersect {mul_op} &&
                       (binsof (a_leg.ones) || binsof (b_leg.ones));

         bins B2_mul_max = binsof (all_ops) intersect {mul_op} &&
                        (binsof (a_leg.ones) && binsof (b_leg.ones));

         ignore_bins others_only =
                                  binsof(a_leg.others) && binsof(b_leg.others);

      }

   endgroup

   op_cov oc;
   zeros_or_ones_on_ops c_00_FF;

   initial begin : coverage
   
      oc = new();
      c_00_FF = new();
   
      forever begin : sample_cov
         @(negedge clk);
         oc.sample();
         c_00_FF.sample();
      end
   end : coverage

//------------------------------------------------------------------------------
// Clock generator
//------------------------------------------------------------------------------

   initial begin : clk_gen
      clk = 0;
      forever begin : clk_frv
         #10;
         clk = ~clk;
      end
   end

//------------------------------------------------------------------------------
// Tester
//------------------------------------------------------------------------------

//---------------------------------
// Random data generation functions

   function operation_t get_op();
      bit [2:0] op_choice;
      op_choice = $random;
      case (op_choice)
        3'b000 : return no_op;
        3'b001 : return add_op;
        3'b010 : return and_op;
        3'b011 : return xor_op;
        3'b100 : return mul_op;
        3'b101 : return no_op;
        3'b110 : return rst_op;
        3'b111 : return rst_op;
      endcase // case (op_choice)
   endfunction : get_op

//---------------------------------
   function byte get_data();
      bit [1:0] zero_ones;
      zero_ones = $random;
      if (zero_ones == 2'b00)
        return 8'h00;
      else if (zero_ones == 2'b11)
        return 8'hFF;
      else
        return $random;
   endfunction : get_data

//------------------------
// Tester main
   
   initial begin : tester
      reset_n = 1'b0;
      @(negedge clk);
      @(negedge clk);
      reset_n = 1'b1;
      start = 1'b0;
      repeat (1000) begin : tester_main
         @(negedge clk);
         op_set = get_op();
         A = get_data();
         B = get_data();
         start = 1'b1;
         case (op_set) // handle the start signal
           no_op: begin : case_no_op
              @(posedge clk);
              start = 1'b0;
           end
           rst_op: begin : case_rst_op
              reset_n = 1'b0;
              start = 1'b0;
              @(negedge clk);
              reset_n = 1'b1;
           end
           default: begin : case_default
              wait(done);
              start = 1'b0;
           end
         endcase // case (op_set)
         // print coverage after each loop
         // can also be used to stop the simulation when cov=100%
         // $strobe("%0t %0g",$time, $get_coverage());
      end
      $finish;
   end : tester

//------------------------------------------------------------------------------
// Scoreboard
//------------------------------------------------------------------------------

   always @(posedge done) begin : scoreboard
      shortint predicted_result;
      #1;
      case (op_set)
        add_op: predicted_result = A + B;
        and_op: predicted_result = A & B;
        xor_op: predicted_result = A ^ B;
        mul_op: predicted_result = A * B;
      endcase // case (op_set)

      if ((op_set != no_op) && (op_set != rst_op))
        if (predicted_result != result)
          $error ("FAILED: A: %0h  B: %0h  op: %s result: %0h",
                  A, B, op_set.name(), result);

   end : scoreboard
   
endmodule : top

// Adder in the Adder/Accumlator
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012

module Adder
    ( input wire [7:0] new_operand,
      input wire [15:0] current_value,

      output wire [15:0] output_value );

//    reg [15:0] internal_value;

    wire adder_1_carry_out;
    wire [7:0] adder_1_sum_out;

    wire adder_2_carry_out;
    wire [7:0] adder_2_sum_out;

    /* string together two 8-bit adders into a 16-bit adder */
    CarryLookaheadAdder lsb_adder
        (.X(new_operand),
         .Y(current_value[7:0]),
         .C0(1'b0),
         .sum(adder_1_sum_out),
         .carry_out(adder_1_carry_out));

    CarryLookaheadAdder msb_adder
        (.X(8'b0),
         .Y(current_value[15:8]),
         .C0(adder_1_carry_out),
         .sum(adder_2_sum_out),
         .carry_out(adder_2_carry_out));

    /* TEMPORARY -- use the built-in Verilog addition */
    /* TODO re-implement with my own carry-look-ahead as per the homework
     * instructions
     *
     * https://en.wikipedia.org/wiki/Lookahead_Carry_Unit#16-bit_adder  
     */

    `ifdef INTERNAL_TEST
    always @(*)
    begin
        output_value <= new_operand + current_value;
    end
    `else
    assign output_value = {adder_2_sum_out,adder_1_sum_out};
    `endif

endmodule
        

// 8-bit Counter
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012

//`define INTERNAL_TEST

module Counter
    ( input wire add,
      input wire reset,
      input wire clock,

      output reg carry_out,
      output reg [7:0] value_out
    );

    reg zero;
    wire internal_carry;
    reg [7:0] one;

    `ifdef INTERNAL_TEST
    reg [8:0] internal_value;
    `else
    reg [7:0] internal_value;

    wire [7:0] adder_output;

    CarryLookaheadAdder adder_1
        (.X(internal_value),
         .Y(one),
         .C0(zero),
         .sum(adder_output),
         .carry_out(internal_carry));
    `endif

    always @(posedge add, posedge reset)
    begin
        if( reset ) 
        begin
            carry_out = 0;
            value_out = 0;
            internal_value = 0;
            one = 1;
            zero= 0;
        end
        else
        begin
            
            /* TEMPORARY ; use the Verilog addition
             * TODO re-implement with my own adder per the assignment
             * instructions
             */
        `ifdef INTERNAL_TEST
            internal_value = internal_value + 1;
            value_out = internal_value[7:0];
            carry_out = internal_value[8];
        `else
            internal_value = adder_output;
            value_out = internal_value;
            carry_out = internal_carry;
        `endif

        end
    end

endmodule


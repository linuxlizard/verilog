// Mux in Adder/Accumulator.
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012

`timescale 1 ns / 10 ps

`include "mux_sel.vh"

module Mux
    ( input wire counter_carry,
      input wire [7:0] counter_value,
      input wire [7:0] register_2_msb,
      input wire [7:0] register_2_lsb,
      input wire [1:0] sel,

      output reg [7:0] data_out
    );

    always @(*)
    begin
        case( sel ) 
            `MUX_SEL_REGISTER_2_LSB : data_out = register_2_lsb;
            `MUX_SEL_REGISTER_2_MSB : data_out = register_2_msb;
            `MUX_SEL_COUNTER_VALUE  : data_out = counter_value;
            `MUX_SEL_COUNTER_CARRY  : data_out = {{7{1'b0}},counter_carry};
//            3: data_out = 8'h0 & counter_value;
        endcase
    end

endmodule


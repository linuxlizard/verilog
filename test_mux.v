// Test the Mux module.
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012

`timescale 1 ns / 10 ps
`include "mux_sel.vh"

module mux_test;
    reg t_carry;
    reg [7:0] t_counter_out;
    reg [7:0] t_register_2_msb;
    reg [7:0] t_register_2_lsb;
    reg [2:0] t_output_sel;

    wire [7:0] mux_output;

    Mux mux1
        (.counter_carry(t_carry),
         .counter_value(t_counter_out),
         .register_2_msb(t_register_2_msb),
         .register_2_lsb(t_register_2_lsb),
         .sel(t_output_sel),
         .data_out(mux_output));

    initial
    begin
        t_carry <= 0;
        t_counter_out <= 0;
        t_register_2_msb <= 0;
        t_register_2_lsb <= 0;
        t_output_sel <= 0;
        # 10;

        t_counter_out <= 8'haa;
        t_register_2_msb <= 8'hbe;
        t_register_2_lsb <= 8'hef;
        t_carry <= 1;
        t_output_sel <= `MUX_SEL_COUNTER_CARRY; 
        # 5;
        $display( "mux_output=%d", mux_output );

        t_output_sel <= `MUX_SEL_COUNTER_VALUE; 
        # 5;
        $display( "mux_output=%d", mux_output );

        t_output_sel <= `MUX_SEL_REGISTER_2_MSB; 
        # 5;
        $display( "mux_output=%d", mux_output );

        t_output_sel <= `MUX_SEL_REGISTER_2_LSB; 
        # 5;
        $display( "mux_output=%d", mux_output );
        
    end

endmodule


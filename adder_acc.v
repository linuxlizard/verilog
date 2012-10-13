//  Adder / Accumulator 
//
//  ECE 4/530 Fall 2012
//
//  David Poole 23-Sep-2012 

`timescale 1 ns / 10 ps

module AdderAccumulator
    ( input wire load,
      input wire add,
      input wire reset,
      input wire clock,
      input wire [7:0] data_in,

      input wire [2:0] output_sel,

      output wire [7:0] data_out
    );

    /* connect from register_1 output to register_2 input */
    wire [7:0] register_1_output;

    wire [15:0] register_2_output;   
    /* most/least signifigant bytes of output of register_2 */
//    wire [7:0] register_2_output_msb;   
//    wire [7:0] register_2_output_lsb;

    /* from Adder to Register2 */
    wire [15:0] adder_output;

    /* from Counter to Output Mux */
    wire counter_carry_out;
    wire [7:0] counter_value_out;

    /* from output mux */
    wire [7:0] mux_data_out;

    Register register_1
        (.clk(clock), 
         .load(load),
         .reset(reset),
         .d(data_in),
         .q(register_1_output));
        defparam register_1.WIDTH = 8;

    Adder adder_1
        (.new_operand(register_1_output),
         .current_value(register_2_output),
         .output_value(adder_output));

    Register register_2
        (.clk(clock), 
         .load(add),
         .reset(reset),
         .d(adder_output),
         .q(register_2_output));
        defparam register_1.WIDTH = 8;

    Counter counter_1
        (.add(add),
         .reset(reset),
         .clock(clock),
         .carry_out(counter_carry_out),
         .value_out(counter_value_out));
    
    Mux mux_1
        (.counter_carry(counter_carry_out),
         .counter_value(counter_value_out),
         .register_2_msb(register_2_output[15:8]),
         .register_2_lsb(register_2_output[7:0]),
         .sel(output_sel),
         .data_out(mux_data_out));


    initial
    begin
//        register_1_output <= 0;
//        register_2_output <= 0;
//        counter_carry_out <= 0;
//        counter_value_out <= 0;
    end

    assign data_out = mux_data_out;

endmodule


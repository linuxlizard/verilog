// TopLevel Testbench for Adder/Accumulator
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012  

`timescale 1 ns / 10 ps

`include "mux_sel.vh"

module adder_accum_testbench;
    reg t_load;
    reg t_add;
    reg t_reset;
    reg t_clk;
    reg [7:0] t_data_in;
    reg [1:0] t_output_sel;

    wire [7:0] t_data_out;

    AdderAccumulator addacc1
        ( .load(t_load),
          .add(t_add),
          .reset(t_reset),
          .clock(t_clk),
          .data_in(t_data_in),
          .output_sel(t_output_sel),
          .data_out(t_data_out));

    integer i;

    initial
    begin
        /* Load clean signals. Reset all sub-blocks */
        t_load = 0;
        t_add = 0;
        t_reset = 1;
        t_clk = 0;
        t_data_in = 0;
        t_output_sel = `MUX_SEL_COUNTER_CARRY; 
//        t_output_sel = `MUX_SEL_REGISTER_2_MSB; 
//        t_output_sel = `MUX_SEL_REGISTER_2_LSB; 
        # 5;

        t_reset = 0;
        # 5;

        /* take system out of reset. Load 0x42 into adder */
//        t_reset = 0;
        t_clk = 1;
        # 5;

        # 5;

        t_clk = 0;
        # 5;

        t_data_in = 8'h42;
        t_load = 1;
        # 5;

        t_clk = 1;
        # 5;

        /* use 0xff to make sure I don't see Register_1 changing */
        t_data_in = 8'hFF;
        t_load = 0;
        # 5;

        t_clk = 0;
        # 5;

        /* Now add. I hope. */
        t_add = 1;
        # 5;

        t_clk = 1;
        # 5;

        t_add = 0;
        # 5;

        t_clk = 0;
        # 5;

        /* Load another value */
        t_data_in = 8'hee;
        t_load = 1;
        # 5;

        t_clk = 1;
        # 5;

        /* use 0xff to make sure I don't see Register_1 changing */
        t_data_in = 8'hFF;
        t_load = 0;
        # 5;

        t_clk = 0;
        # 5;

        /* Now add. I hope. */
        t_add = 1;
        # 5;

        t_clk = 1;
        # 5;

        t_add = 0;
        # 5;

        t_clk = 0;
        # 5;

        for( i=0 ; i<300 ; i=i+1 ) 
        begin
            t_data_in = 8'hfe;
            t_load = 1;
            # 5;

            t_clk = 1;
            # 5;

            t_data_in = 8'hff;
            t_load = 0;
            # 5;

            t_clk = 0;
            # 5;

            t_add = 1;
            #5;

            t_clk = 1;
            # 5;
        
            t_add = 0;
            # 5;

            t_clk = 0;
            # 5;
        end

        t_clk = 1;
#5;

        t_add = 0;
#5;

        t_clk = 0;
#5;

        /* check the counter output */        
//        t_output_sel = `MUX_SEL_COUNTER_VALUE; 
        t_output_sel = `MUX_SEL_COUNTER_VALUE; 
#5;

        t_clk = 1;
#5;

        /* nothing */
#5;

        t_clk = 0;
#5;

        t_reset = 1;
        # 5;

        t_clk = 1;
        # 5;

        # 5;

        t_clk = 0;
        # 5;

    end

endmodule


// TopLevel Testbench for Adder/Accumulator
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012  

`timescale 1 ns / 10 ps

`include "mux_sel.vh"

`define PERIOD 10
`define HALF_PERIOD 5

module test_adder_acc;
    reg t_load;
    reg t_add;
    reg t_reset;
    reg t_clk = 0;
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

    task run_reset;
    begin
        t_reset = 1;
        #`PERIOD;

        t_reset = 0;
        #`PERIOD;
    end
    endtask

    task run_load;
        input value;
    begin
        t_data_in = value;
        t_load = 1;
        #`PERIOD;

        t_load = 0;
        #`PERIOD;
    end
    endtask

    task run_add;
    begin
        t_add = 1;
        #`PERIOD;

        t_add = 0;
        #`PERIOD;
    end
    endtask

    integer i;
    integer test_sum;

    always
    begin
        #`HALF_PERIOD t_clk = ~t_clk;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_adder_acc.vcd");
        $dumpvars(0,test_adder_acc);

        /* Load clean signals. Reset all sub-blocks */
        t_load = 0;
        t_add = 0;
        t_reset = 1;
        t_data_in = 0;
        test_sum = 0;
//        t_output_sel = `MUX_SEL_COUNTER_CARRY; 
//        t_output_sel = `MUX_SEL_REGISTER_2_MSB; 
        t_output_sel = `MUX_SEL_REGISTER_2_LSB; 
        # `PERIOD;

        t_reset = 0;
        # `PERIOD;

        /* take system out of reset. Load 0x42 into adder */
//        t_reset = 0;

        t_data_in = 8'h42;
        t_load = 1;
        test_sum = test_sum + t_data_in;
        $display( "test_sum=0x%x", test_sum );
        #`PERIOD;

        /* use 0xff to make sure I don't see Register_1 changing */
        t_data_in = 8'hFF;
        t_load = 0;
        #`PERIOD;

        /* Now add. I hope. */
        t_add = 1;
        #`PERIOD;
        t_add = 0;
        #`PERIOD;
        $display( "t_data_out=0x%x",t_data_out);

        /* Load another value */
        t_data_in = 8'hee;
        t_load = 1;
        test_sum = test_sum + t_data_in;
        $display( "test_sum=0x%x", test_sum );
        #`PERIOD;

        /* use 0xff to make sure I don't see Register_1 changing */
        t_data_in = 8'hFF;
        t_load = 0;
        #`PERIOD;

        /* run the add */
//        t_add = 1;
//        #`PERIOD;
//        t_add = 0;
//        #`PERIOD;
        run_add;
        $display( "t_data_out=0x%x",t_data_out);

        /* get the MSB */
        t_output_sel = `MUX_SEL_REGISTER_2_MSB; 
        # `PERIOD;
        $display( "t_data_out=0x%x",t_data_out);

        run_reset;

        run_load(1);

        /* Multiple adds */
        for( i=0 ; i<300 ; i=i+1 ) 
        begin
            run_add;

            t_output_sel = `MUX_SEL_REGISTER_2_LSB; 
            # `PERIOD;
            $display( "total_LSB=0x%x", t_data_out );

            t_output_sel = `MUX_SEL_REGISTER_2_MSB; 
            # `PERIOD;
            $display( "total_MSB=0x%x", t_data_out );
        end

        /* check the counter output */        
        t_output_sel = `MUX_SEL_COUNTER_VALUE; 
        #`PERIOD;
        $display( "counter=%d", t_data_out );
        t_output_sel = `MUX_SEL_COUNTER_CARRY; 
        #`PERIOD;
        $display( "counter_carry=%d", t_data_out );

        t_reset = 1;
        #`PERIOD;

        $finish;
    end

endmodule


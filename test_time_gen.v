// ECE 4/530 Fall 2012
//
// David Poole 27-Oct-2012
//
// Time Generation test bench

`timescale 1 ns / 10 ps

`define PERIOD 20   // 50Mhz at timescale=1ns
`define HALF_PERIOD 10

module test_time_gen;
    reg mclk = 1'b0;
    reg t_reset = 1'b1;

    reg t_fast_mode=1'b1;

    wire t_one_second;
    wire t_one_minute;

    TIME_GEN run_time_gen
        (.clk256(mclk),
         .reset(t_reset),
         .fast_mode( t_fast_mode ),
         .one_second(t_one_second),
         .one_minute(t_one_minute) );
   
    /* This is the clock */
    always
    begin
        #`HALF_PERIOD mclk = ~mclk;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_time_gen.vcd");
        $dumpvars(0,test_time_gen);

        $monitor( "%d %d %d",t_one_second, t_one_minute, $time );
        # `PERIOD;
        @(negedge mclk);
        t_reset = ~t_reset;
        # `PERIOD;

        # 100000;
        $finish;
    end

endmodule


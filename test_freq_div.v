// ECE 4/530 Fall 2012
//
// David Poole 27-Oct-2012
//
// Frequency Divider test bench

`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

module test_freq_div;
    reg mclk = 1'b0;
    reg reset = 1'b1;

    wire clk_out;

    FREQ_DIV #(8) run_freq_div
        (.clk(mclk),
         .reset(reset),
         .clk256(clk_out) );
   
    /* This is the clock */
    always
    begin
        #`HALF_PERIOD mclk = ~mclk;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_freq_div.vcd");
        $dumpvars(0,test_freq_div);

        $monitor( "%d",clk_out );
        @(negedge mclk);
        reset = ~reset;
        # `PERIOD;

        # 1000;
        $finish;
    end

endmodule


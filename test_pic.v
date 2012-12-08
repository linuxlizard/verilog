// Test PIC
//
// David Poole
// ECE530 Fall 2012
//

`timescale 1 ns / 10 ps

`include "pic.vh"

module test_pic;

    parameter period  = 10;
    parameter half_period = 5;

    reg MCLK = 1'b0;

    // this project uses an nReset so start at zero (reset enabled)
    reg reset = 1'b0;

    wire [7:0] data_wire;
    reg [7:0] t_data = 8'hff;
    reg [1:0] t_select = `SEL_OCR;
    reg t_readwrite = `RW_READ;
    reg [7:0] t_intreq;
    reg t_intack;
    wire t_int;
    reg [7:0] t_test= 8'h00;

    /* This is the clock */
    always
    begin
        #half_period MCLK = ~MCLK;
    end

    assign data_wire = t_data;

    pic run_pic
        (.clk(MCLK),
         .reset(reset),
         .data(data_wire),
         .select(t_select),
         .readwrite(t_readwrite),
         .intreq(t_intreq),
         .intack(t_intack),

         // output(s)
         .int(t_int));

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_pic.vcd");
        $dumpvars(0,test_pic);

        $monitor("%d int=%d data=%x", $time, t_int, data_wire );

        # period;
        # period;

        reset = 1'b1;
//        # period;

        t_test = 8'h01;
        t_data = 8'hzz;
        t_select = `SEL_OCR;
        t_readwrite = `RW_READ;
        # period;
        # period;

        t_test = 8'h02;
        t_select = `SEL_OCR;
        t_data = 8'haa;
        t_readwrite = `RW_WRITE;
        # period;

        t_test = 8'h03;
        t_data = 8'hzz;
        t_select = `SEL_IMR;
        t_readwrite = `RW_READ;
        # period;

        t_test = 8'h04;
        t_data = 8'hzz;
        t_select = `SEL_OCR;
        t_readwrite = `RW_READ;
        # period;

        t_test = 8'h05;
        t_data = 8'h22;
        t_select = `SEL_IMR;
        t_readwrite = `RW_WRITE;
        # period;

        t_test = 8'h03;
        t_data = 8'hzz;
        t_select = `SEL_IMR;
        t_readwrite = `RW_READ;
        # period;

//        # 1000;
        # period;
        # period;
        # period;
        $finish;
    end

endmodule


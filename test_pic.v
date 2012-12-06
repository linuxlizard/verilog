`timescale 1 ns / 10 ps

module test_pic;

    parameter period  = 10;
    parameter half_period = 5;

    reg MCLK = 1'b0;

    // this project uses an nReset so start at zero (reset enabled)
    reg reset = 1'b0;

    wire [7:0] t_data;
    reg [1:0] t_select;
    reg t_readwrite;
    reg [7:0] t_IR;
    reg t_intack;
    wire t_int;

    /* This is the clock */
    always
    begin
        #half_period MCLK = ~MCLK;
    end

    pic run_pic
        (.clk(MCLK),
         .reset(reset),
         .data(t_data),
         .select(t_select),
         .readwrite(t_readwrite),
         .IR(t_IR),
         .intack(t_intack),

         // output(s)
         .int(t_int));

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_pic.vcd");
        $dumpvars(0,test_pic);

        $monitor("%d int=%d", $time, t_int );

        # period;
        # period;


        reset = 1'b1;
        # period;

        # 1000;
        $finish;
    end

endmodule


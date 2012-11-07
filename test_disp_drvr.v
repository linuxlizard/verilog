`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

module test_disp_drvr();

    reg MCLK = 1'b0;
    reg reset = 1'b1;
    reg t_do_snooze = 1'b0;
    reg t_stop_alarm = 1'b0;
    reg [15:0] t_alarm_time = 16'h1234;
    reg [15:0] t_current_time = 16'h1234;
    reg t_show_alarm = 1'b0;

    wire [15:0] t_display;
    wire t_sound_alarm;

    wire [7:0] t_debug_snooze;
    wire [2:0] t_debug_state_out;

    DISP_DRVR run_disp_drvr
        (.clk(MCLK),
         .reset(reset),
         .do_snooze(t_do_snooze),
         .stop_alarm(t_stop_alarm),
         .alarm_time(t_alarm_time),
         .current_time(t_current_time),
         .show_alarm(t_show_alarm),

         /* outputs */
         .display(t_display),
         .int_sound_alarm(t_sound_alarm),
         .debug_snooze(t_debug_snooze),
         .debug_state_out(t_debug_state_out)
        );

    /* This is the clock */
    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_disp_drvr.vcd");
        $dumpvars(0,test_disp_drvr);

        $monitor( "%d display=%x sound_alarm=%d", $time, t_display,
                t_sound_alarm );

        @(negedge MCLK);
        reset = 1'b0;

        # `PERIOD 
        # `PERIOD 

        // hit the snooze button
        t_do_snooze = 1'b1;
        # `PERIOD 
        // release the snooze button
        t_do_snooze = 1'b0;
        # `PERIOD 

        # 100;
        $finish;
    end
endmodule


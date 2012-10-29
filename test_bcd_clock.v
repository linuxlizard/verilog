// BCD Clock  hours/minutes
//
// Add one minute. Ripple carry.
//
// ECE 4/530 Fall 2012
//
// David Poole 28-Oct-2012

`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

module test_bcd_clock;

    reg t_add = 0;
    reg [3:0] t_ms_hour = 0;
    reg [3:0] t_ls_hour = 0;
    reg [3:0] t_ms_min = 0;
    reg [3:0] t_ls_min = 0;

    wire [3:0] t_ms_hour_out;
    wire [3:0] t_ls_hour_out;
    wire [3:0] t_ms_min_out;
    wire [3:0] t_ls_min_out;

    bcd_clock run_bcd_clock
        (.add_one(t_add),
         .ms_hour(t_ms_hour),
         .ls_hour(t_ls_hour),
         .ms_min(t_ms_min),
         .ls_min(t_ls_min),
         
         .out_ms_hour(t_ms_hour_out),
         .out_ls_hour(t_ls_hour_out),
         .out_ms_min(t_ms_min_out),
         .out_ls_min(t_ls_min_out)
         
         );

    task test_time;
        input [3:0] ms_hour;
        input [3:0] ls_hour;
        input [3:0] ms_min;
        input [3:0] ls_min;
    begin
        t_ms_hour = ms_hour;
        t_ls_hour = ls_hour;
        t_ms_min = ms_min;
        t_ls_min = ls_min;
        t_add <= 1;
        # 80;

        t_add <= 0;
        # 80;
    end
    endtask

    task run_clock;
        integer i;
    begin
        t_ms_hour = 0;
        t_ls_hour = 0;
        t_ms_min = 0;
        t_ls_min = 1;
        // run the clock for a day
        for( i=0 ; i<60*24; i=i+1 ) 
        begin

            t_add <= 1;
            # 80;

            t_add <= 0;
            # 80;

            // read back values, make next input
            t_ms_hour = t_ms_hour_out;
            t_ls_hour = t_ls_hour_out;
            t_ms_min = t_ms_min_out;
            t_ls_min = t_ls_min_out;
        end
    end
    endtask

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_bcd_clock.vcd");
        $dumpvars(0,test_bcd_clock);

        $monitor( "%d%d : %d%d", t_ms_hour_out, t_ls_hour_out, 
                                t_ms_min_out, t_ls_min_out );

        t_add <= 0;

        test_time( 0, 0, 0, 1 );
        test_time( 1, 1, 1, 1 );
        test_time( 1, 2, 3, 4 );
        test_time( 1, 2, 5, 9 );
        test_time( 0, 1, 5, 9 );
        test_time( 0, 9, 0, 0 );
        test_time( 1, 9, 0, 0 );
        test_time( 1, 9, 5, 9 );
        test_time( 1, 9, 5, 9 );
        test_time( 2, 0, 5, 9 );
        test_time( 2, 0, 2, 9 );
        test_time( 2, 3, 5, 9 ); // toughest case -- midnight rolls to 00:00

        run_clock;
        $finish;

        t_ms_hour = 1;
        t_ls_hour = 2;
        t_ms_min = 5;
        t_ls_min = 9;
        t_add <= 1;
        # 80;

        t_add <= 0;
        # 80;

        t_ms_hour = 1;
        t_ls_hour = 2;
        t_ms_min = 3;
        t_ls_min = 4;
        t_add <= 1;
        # 80;

        t_add <= 0;
        # 80;

        t_ms_hour = 1;
        t_ls_hour = 9;
        t_ms_min = 5;
        t_ls_min = 9;
        t_add <= 1;
        # 80;

        t_add <= 0;
        # 80;

        t_ms_hour = 2;
        t_ls_hour = 3;
        t_ms_min = 5;
        t_ls_min = 9;
        t_add <= 1;
        # 80;

        $finish;
    end

endmodule


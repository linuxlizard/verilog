`timescale 1 ns / 10 ps

`define PERIOD 10
`define HALF_PERIOD 5

module test_al_clk_counter;

    reg MCLK=0;

    /* This is the clock */
    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end

    localparam clock_div = 1;  
    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(t_reset),
         .clk256(t_clk256) );

    wire t_clk256;
    reg t_reset=1;
    reg t_one_minute=0;
    reg [15:0] t_time_in=0;
    reg t_load_new_time=0;

//    reg [15:0] t_current_time_out;

    wire [15:0] t_current_time_out;
    
    al_clk_counter run_al_clk_counter
        ( .clk256(t_clk256),
          .reset(t_reset),
          .one_minute(t_one_minute),
          .time_in(t_time_in),
          .load_new_time(t_load_new_time),
          .current_time_out(t_current_time_out));

    integer i;

    initial
    begin

        $display("Hello, world");
        $dumpfile("test_al_clk_counter.vcd");
        $dumpvars(0,test_al_clk_counter);

        $monitor( "%d %x", $time, t_current_time_out );

        # `PERIOD;
        @(negedge MCLK);
        t_reset = ~t_reset;
        # `PERIOD;

        t_time_in = 16'h1236;  /* 12:36 pm */
        t_load_new_time = 1;
        # `PERIOD;

        t_load_new_time = 0;
        # `PERIOD;

        @(posedge t_clk256)
        t_one_minute = 1;     /* +1 minute*/
        # `PERIOD;

        t_one_minute = 0;
        # `PERIOD;

        t_time_in = t_current_time_out;
        # `PERIOD;

        @(posedge t_clk256)
        t_one_minute = 1;     /* +1 minute*/
        # `PERIOD;

        t_one_minute = 0;
        # `PERIOD;

        t_time_in = t_current_time_out;
        # `PERIOD;

        // run 10 minutes
        for( i=0 ; i<10 ; i=i+1 ) 
        begin
            $display( "i=%d", i );
            @(posedge t_clk256)
            t_one_minute = 1;
            # `PERIOD;

            t_one_minute = 0;
            # `PERIOD;

            t_time_in = t_current_time_out;
            # `PERIOD;
        end

        # 1000;
        $finish;
    end

endmodule



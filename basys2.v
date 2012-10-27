`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

`include "mux_sel.vh"

`define ASSERT_EQUALS(x,y) \
        repeat(1)\
        begin\
            if( (x) != (y) ) \
            begin\
                $write( "assert failed %d != %d\n", (x), (y) );\
                $finish(1);\
            end\
        end

`define BTN_ALL_OFF 4'd0
`define BTN_RESET   4'd1
`define BTN_LOAD    4'd2
`define BTN_ADD     4'd4

module basys2;

    reg MCLK = 0;
    reg [7:0] sw = 8'd0;
    reg [3:0] btn = `BTN_ALL_OFF;

    wire [7:0] Led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    top_adder_accumulator run_adder_acc
        (.MCLK(MCLK),
         .Led(Led),
         .sw(sw),
         .seg(seg),
         .an(an),
         .dp(dp),
         .btn(btn) );

    task run_add;
    begin
        // push add
        btn = `BTN_ADD; 
        #`PERIOD;

        btn = `BTN_ALL_OFF; 
        // delay for several periods; we have a lot of clocks to percolate
        // through
        #80;
    end
    endtask

    /* This is the clock */
    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end

    integer i;
    integer lsb, msb;
    integer current_total;
    integer sanity_sum;

    initial
    begin
        $display("Hello, world");
        $dumpfile("basys2.vcd");
        $dumpvars(0,basys2);

        sw = 8'd0;
        # `PERIOD;

        // push & release reset button
        btn = `BTN_RESET; // push reset button0
        #`PERIOD;

        btn = `BTN_ALL_OFF;
        #`PERIOD;
        #`PERIOD;
        #`PERIOD;

        `ASSERT_EQUALS( 1, 1 )

        // load register 1 with a value
        sw = 8'd2;
        btn = `BTN_LOAD; // push load button1
        #20;
        #20;
        #20;
        #20;
        sw = 8'd0; // Register2_LSB
        btn = `BTN_ALL_OFF;  // release all buttons
        #20;
        
        // push add
        run_add;
        sanity_sum = 0;
        sanity_sum = sanity_sum + 2;

        $display( "seg=", seg );
        #`PERIOD;
        $display( "seg=", seg );
        #`PERIOD;
        $display( "seg=", seg );
        #`PERIOD;
        $display( "seg=", seg );
        #`PERIOD;

        // push add again
//        btn = `BTN_ADD; 
//         #20;
//        btn = `BTN_ALL_OFF; 
//        #80;
        run_add;
        sanity_sum = sanity_sum + 2;

        $display( "seg=", seg );
        #`PERIOD;

        // set switches to display counter
        $display( "set switches to mux counter value" );
        sw = `MUX_SEL_COUNTER_VALUE; 
        #80;

        $display( "seg=", seg );
        #`PERIOD;

        $display( "set switches to LSB " );
        sw = `MUX_SEL_REGISTER_2_LSB; 
        #80;
        $display( "seg=%d", seg );
        #`PERIOD;

        /* Multiple adds */
        for( i=0 ; i<300 ; i=i+1 ) 
        begin
            run_add;

            sw = `MUX_SEL_REGISTER_2_LSB; 
            # `PERIOD;
            $display( "total_LSB=0x%x", seg );

            lsb = seg;

            sw = `MUX_SEL_REGISTER_2_MSB; 
            # `PERIOD;
            $display( "total_MSB=0x%x", seg );

            msb = seg;

            sanity_sum = sanity_sum + 2;
            current_total = (msb<<8) | lsb;
            $display( "sanity=%d current_total=%d", sanity_sum, current_total );

            `ASSERT_EQUALS(sanity_sum, current_total)

        end

        // reset
 //       btn = `BTN_RESET; 
 //        #20;
 //       btn = `BTN_ALL_OFF; 
 //       #80;

        $finish;
    end

endmodule


`timescale 1 ns / 10 ps
`define PERIOD 10

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

    always
    begin
        #`PERIOD MCLK = ~MCLK;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("basys2.vcd");
        $dumpvars(0,basys2);

        # 5;

        // push & release reset button
        sw = 8'd1;
        btn = `BTN_RESET; // push reset button0
        # 10;

        btn = `BTN_ALL_OFF;
        # 10;
        # 10;
        # 10;

//        `ASSERT_EQUALS( 1, 1 )

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
        btn = `BTN_ADD; 
         #20;
        btn = `BTN_ALL_OFF; 
        #80;


        $display( "seg=", seg );
        #10;
        $display( "seg=", seg );
        #10;
        $display( "seg=", seg );
        #10;
        $display( "seg=", seg );
        #10;

        // push add again
        btn = `BTN_ADD; 
         #20;
        btn = `BTN_ALL_OFF; 
        #80;

        $display( "seg=", seg );
        #10;


        // set switches to display counter
        $display( "set switches to mux counter value" );
        sw = `MUX_SEL_COUNTER_VALUE; 
        #80;

        $display( "seg=", seg );
        #10;

        $display( "set switches to LSB " );
        sw = `MUX_SEL_REGISTER_2_LSB; 
        #80;
        $display( "seg=", seg );
        #10;

        // reset
 //       btn = `BTN_RESET; 
 //        #20;
 //       btn = `BTN_ALL_OFF; 
 //       #80;

    end

endmodule


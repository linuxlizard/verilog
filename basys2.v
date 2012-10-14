`timescale 1 ns / 10 ps
`define PERIOD 10

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
    wire [6:0] seg = 7'd0;
    wire [3:0] an;
    wire dp = 0;

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

//        `ASSERT_EQUALS( 1, 1 )

        // load register 1 with a value
        sw = 8'd1;
        btn = `BTN_LOAD; // push load button1
        #10;
        btn = `BTN_ALL_OFF;  // release all buttons
        #10;
        
        // push add
        btn = `BTN_ADD; 
         #10;
        btn = `BTN_ALL_OFF; 
         #10;


        $display( "seg=", seg );
        #10;
        $display( "seg=", seg );
        #10;
        $display( "seg=", seg );
        #10;
        $display( "seg=", seg );
        #10;

        # 100;
        $finish;
    end

endmodule


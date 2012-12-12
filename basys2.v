`timescale 1 ns / 10 ps

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
`define BTN_IRQ_REQ 4'd2
`define BTN_INT_ACK 4'd4
`define BTN_ROM_EXE 4'd8

module basys2;

    parameter period = 10;
    parameter half_period = 5;

    reg MCLK = 0;
    reg [7:0] sw = 8'd0;
    reg [3:0] btn = `BTN_RESET; // reset

    wire [7:0] Led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;

    integer debug_num = 0;

    /* This is the clock */
    always
    begin
        #half_period MCLK = ~MCLK;
    end

    wire [87:72] PIO;

    top_pic run_top_pic
        ( .MCLK(MCLK),
          .sw(sw),
          .btn(btn),
          .PIO(PIO),
          .Led(Led),
          .seg(seg),
          .an(an),
          .dp(dp) );

    task step_rom;
    begin
        btn = `BTN_ROM_EXE; # period;
        btn = `BTN_ALL_OFF; # period;
        /* need some delay between rom steps */
        # period; # period; # period;
    end
    endtask

    task push_intack_button;
    begin
        btn = `BTN_INT_ACK;
        # period;
        # period;
        btn = `BTN_ALL_OFF;
        # period;
        # period;
    end
    endtask

    initial
    begin
        $display("Hello, world");
//        $dumpfile("basys2.vcd");
//        $dumpvars(0,basys2);

//        $monitor( "%d Led=%x disp=%b%b",$time, Led, an, seg );

        btn = `BTN_RESET; // reset
        # period;

        @(negedge MCLK);
        btn = `BTN_ALL_OFF; // turn off reset
        # period;
        # period;


        /* trigger the first two ROM reads to set up the PIC */
        debug_num = 1;
        step_rom;
        debug_num = 2;
        step_rom;

        /* one more for jenny and the wimp */
        debug_num = 3;
        step_rom;

//        #70000;
//        $finish;

        // trigger an interrupt by setting the switches to the IRQ we want then
        // pushing the btn to strobe the values into IRR
        debug_num = 4;
        sw = 8'h81; /* IRQ 0 and 7 */
        btn = `BTN_IRQ_REQ;
        # period;
        btn = `BTN_ALL_OFF;
        # period;
        
        /* clear the incoming pending interrupt switches */
        sw = 8'h0;

        $display("pulsing intackN" );
        debug_num = 5;
        /* inack pulse (down, up) */
        push_intack_button;
        push_intack_button;

        /* first interrupt handled should be 7 */
        /* next ROM is a read ISR */
        debug_num = 6;
        step_rom;

        debug_num = 7;
        step_rom;

        /* big delay then ack the 2nd interrupt */
        # period; # period; # period; # period;
        # period; # period; # period; # period;

        /* second intack pulse */
        debug_num = 8;
        /* intack pulse (down, up) */
        push_intack_button;
        push_intack_button;
        
        /* now clear the 2nd interrupt; should see IRQ0 being handled*/
        debug_num = 9;
        push_intack_button;
        push_intack_button;

        debug_num = 10;
        push_intack_button;
        push_intack_button;

        debug_num = 11;
        #70000;
        $finish;
    end

endmodule


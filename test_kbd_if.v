// ECE 4/530 Fall 2012
//
// David Poole 01-Nov-2012
//
// KBD Interface Test Bench
//

`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

`include "keycodes.vh"

`include "bcd_clockf.vh"

module test_kbd_if;

    reg MCLK = 0;

    wire ps2c=0;
    wire ps2d=0;

    reg int_reset=1;
    reg int_shift=0;
    reg int_set_alarm = 0;
    reg int_set_time = 0;

    wire [31:0] int_key_buffer;
    wire [7:0] int_key;

    wire wire_set_alarm;
    wire wire_set_time;

    kbd_if run_kbd_if 
        ( .clk(MCLK),
          .reset(int_reset),
          .shift(int_shift),

          .PS2C(ps2c),
          .PS2D(ps2d),

          .key_buffer(int_key_buffer),
          .key(int_key),
          .set_alarm(wire_set_alarm),
          .set_time(wire_set_time) );

    /* This is the clock */
    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end

//    assign key_buffer = int_key_buffer;

    // Mealy state machine
    // simple way to shift in a new keycode whenever a value key is pushed
`define STATE_START       0
`define STATE_STORE_KEY 1
`define STATE_WAITING     2

    reg [3:0] shift_state=`STATE_START;
    reg [3:0] shift_next_state=`STATE_START;

    always @(posedge(MCLK))
    begin
        shift_state <= shift_next_state;
    end

    always @(shift_state,int_key) 
    begin
        case( shift_state )
            `STATE_START :
                begin
                    int_shift <= 0;
                    // has a key been pressed? */
                    if( int_key != 8'hff )
                        shift_next_state <= `STATE_STORE_KEY;
                end

            `STATE_STORE_KEY :
                begin
                    int_shift <= 1;
                    shift_next_state <= `STATE_START;
                end

            default :
                shift_next_state = `STATE_START;
        endcase
    end


    initial
    begin
        $display("Hello, world");
        $dumpfile("test_kbd_if.vcd");
        $dumpvars(0,test_kbd_if);

        $monitor( "%d shift=%d %x %x %d", MCLK, int_shift, int_key_buffer, int_key, $time );

        int_reset = 1;
        int_shift = 0;

        @(negedge MCLK);
        int_reset = ~int_reset;
        # `PERIOD;

        # 2000;

        $finish;
    end
          
endmodule


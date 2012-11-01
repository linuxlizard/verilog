// ECE 4/530 Fall 2012
//
// David Poole 01-Nov-2012
//
// KBD Interface Test Bench
//

`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

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
        ( .clk256(MCLK),
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
`define SHIFT_STATE_START       0
`define SHIFT_STATE_READING_KEY 1
`define SHIFT_STATE_WAITING     2

    reg [3:0] shift_state=`SHIFT_STATE_START;
    reg [3:0] shift_next_state=`SHIFT_STATE_START;

    always @(posedge(MCLK))
    begin
        shift_state <= shift_next_state;
    end

    always @(shift_state,int_key) 
    begin
        case( shift_state )
            `SHIFT_STATE_START :
                begin
                    int_shift <= 0;
                    if( int_key != 8'h0 )
                        shift_next_state <= `SHIFT_STATE_READING_KEY;
                end

            `SHIFT_STATE_READING_KEY :
                begin
                    int_shift <= 1;
                    shift_next_state <= `SHIFT_STATE_WAITING;
                end

            `SHIFT_STATE_WAITING :
                begin
                    int_shift <= 0;
                    shift_next_state <= `SHIFT_STATE_START;
                end

            default :
                shift_next_state = `SHIFT_STATE_START;
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

        # 200;

        $finish;
    end
          
endmodule


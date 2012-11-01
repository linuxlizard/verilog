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

    // simple way to shift in a new keycode whenever a value key is pushed
    always @(posedge(MCLK),int_key) 
    begin
        if( int_key == 8'h0 )
            int_shift <= 0;
        else 
            int_shift <= 1;
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


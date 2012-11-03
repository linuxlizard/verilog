`timescale 1 ns / 10 ps

module alarm_clock 
    ( input MCLK,
      input [7:0] sw,
      input [7:0] btn;

      inout PS2C,
      inout PS2D,

      output [7:0] Led,
      output [6:0] seg,
      output an,
      output dp );

    wire [6:0] int_seg;
    wire [3:0] int_an;
    wire int_dp;

`ifdef SIMULATION
    localparam clock_div = 2;  
`else
//    localparam clock_div = 195312;  // 50Mhz -> 256Hz
    localparam clock_div = 97656;  // 25Mhz -> 256Hz
`endif

    wire fast_mode;  /* sw0 */
    wire reset;

    assign fast_mode = sw[0];
    assign reset = sw[7];

    /*
     *  FRE_DIV
     */

    wire clk256;

    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(reset),
         .clk256(clk256) );

    /*
     *  TIME_GEN
     */
    wire one_second;
    wire one_minute;

    TIME_GEN run_time_gen
        (.clk256(clk256),
         .reset(reset),
         .fast_mode(fast_mode),
         .one_second(one_second),
         .one_minute(one_minute) );

    /* 
     *  Seven Segment Display 
     */
`ifdef SIMULATION
    stub_digits_to_7seg run_digits_to_7seg 
`else
    hex_to_7seg run_digits_to_7seg 
`endif
        ( .rst(reset),
          .mclk(MCLK),
          .word_in( {bcd_ms_hour,bcd_ls_hour,bcd_ms_min,bcd_ls_min} ),
          .display_mask_in(4'b1111),
          .seg(int_seg),
          .an(int_an),
          .dp(int_dp) );

    assign seg = int_seg;
    assign an = int_an;
    assign dp = int_dp;

    /*
     *   KBD_IF 
     */
    reg int_shift;
    reg [7:0] key_code;
    wire [31:0] int_key_buffer;
    wire [7:0] int_key;
    wire wire_set_alarm;
    wire wire_set_time;

    kbd_if run_kbd_if 
        ( .clk(MCLK),
          .reset(int_reset),
          .shift(int_shift),

          .PS2C(PS2C),
          .PS2D(PS2D),

          .key_buffer(int_key_buffer),
          .key(key_code),
          .set_alarm(wire_set_alarm),
          .set_time(wire_set_time) );

    /*
     *  AL_Controller
     */

    AL_Controller run_al_controller
        (.clk256(clk256),
         .reset(int_reset),
         .one_second(one_second),
         .key(),
         .set_alarm(),
         .set_time(),

         .load_alarm(),
         .show_alarm(),
         .shift(),
         .load_new_time());


endmodule


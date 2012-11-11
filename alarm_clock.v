`timescale 1 ns / 10 ps

module alarm_clock 
    ( input MCLK,
      input [7:0] sw,
      input [3:0] btn,

      input PS2C,
      input PS2D,

      /* JA 1,2,3,4 (used with debugging) */
      output [87:72] PIO, 

      output [7:0] Led,
      output [6:0] seg,
      output [3:0] an,
      output dp );

    wire fast_mode;  /* sw0 */
    wire reset; /* sw7 */

    assign fast_mode = sw[0];
    assign reset = sw[7];
    
//    assign PIO[73] = MCLK;
//    assign PIO[74] = sw[2];
//    assign PIO[75] = sw[3];
//    assign PIO[76] = sw[4];
//    assign PIO[77] = MCLK;
//    assign PIO[87] = ac;

//    assign B2 = sw[1];
//    assign A3 = sw[2];
//    assign J3 = sw[3];
//    assign B5 = sw[4];

    /*
     * Edge to Pulse Snooze and Alarm Off
     */

    wire ac_snooze_button;
    wire ac_alarm_off_button;

    edge_to_pulse snooze_button_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[0]),
         .pulse_out(ac_snooze_button));
    edge_to_pulse alarm_button_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[1]),
         .pulse_out(ac_alarm_off_button));

    /*
     *  FREQ_DIV to 256Hz
     */

    wire ac_clk256;

    assign PIO[75:72] = {4{1'bZ}};
//    assign PIO[83:72] = {12{1'bZ}};
//
//    assign PIO[83:77] = ac_key_code;

//    assign PIO[87] = ac_clk256;

`ifdef SIMULATION
    localparam clock_div = 1;  /* counts 0,1,0,1,0,1,0,1,... */
`else
//    localparam clock_div = 195312;  // 50Mhz -> 256Hz
    localparam clock_div = 97656;  // 25Mhz -> 256Hz
`endif

    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(reset),

         /* outputs */
         .clk256(ac_clk256) );

    /*
     *  TIME_GEN
     */
    wire ac_one_second_level;
    wire ac_one_minute_level;

    wire ac_one_second;
    wire ac_one_minute;

    TIME_GEN run_time_gen
        (.clk256(ac_clk256),
         .reset(reset),
         .fast_mode(fast_mode),

         /* outputs */
         .one_second(ac_one_second_level),
         .one_minute(ac_one_minute_level) );

    edge_to_pulse second_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(ac_one_second_level),
         .pulse_out(ac_one_second));
    edge_to_pulse minute_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(ac_one_minute_level),
         .pulse_out(ac_one_minute));

    /* debug counters on second/minute for simulation */
`ifdef SIMULATION
    integer ac_debug_second_counter = 0;
    integer ac_debug_minute_counter = 0;
    always @(posedge(ac_one_second))
    begin
        ac_debug_second_counter = ac_debug_second_counter + 1;
    end
    always @(posedge(ac_one_minute))
    begin
        ac_debug_minute_counter = ac_debug_minute_counter + 1;
    end
`endif

    /* 
     *  Seven Segment Display 
     */

    wire [15:0] ac_7seg_input;

    wire [6:0] ac_seg;
    wire [3:0] ac_an;
    wire ac_dp;

    assign seg = ac_seg;
    assign an = ac_an;
    assign dp = ac_dp;

    wire [15:0] ac_key_buffer;

`ifdef foo_SIMULATION
    stub_digits_to_7seg run_digits_to_7seg 
`else
    hex_to_7seg run_digits_to_7seg 
`endif
        ( .rst(reset),
          .mclk(MCLK),
//          .word_in( ac_key_buffer ),
          .word_in( ac_7seg_input ),
          .display_mask_in(4'b1111),

          /* outputs */
          .seg(ac_seg),
          .an(ac_an),
          .dp(ac_dp) );

    /*
     *   KBD_IF 
     */
//    wire ac_shift;
    wire [7:0] ac_key_code;
//    wire [15:0] ac_key_buffer;

//    assign PIO[83:76] = ac_key_code;

//    reg ac_kbd_active=0;

//    wire kbd_reset;

    kbd_if run_kbd_if 
        ( .clk(MCLK),
          .reset(reset),
//          .kbd_shift(ac_shift),

//          .kbd_clear(ac_kbd_clear), // deviation from spec

          .PS2C(PS2C),
          .PS2D(PS2D),

          /* outputs */
//          .key_buffer(ac_key_buffer),
          .key(ac_key_code)
//          .kbd_active(ac_kbd_active) // deviation from spec
//          .set_alarm(wire_set_alarm),
//          .set_time(wire_set_time) 
        );

    /*
     *  AL_Controller
     */

    wire ac_load_alarm;
    wire ac_show_alarm;
    wire ac_load_new_time;
    wire ac_show_keyboard;

    wire [3:0] alc_state;
    wire [7:0] alc_seconds_time;

    AL_Controller run_al_controller
        ( .clk(MCLK),
          .reset(reset),
          .one_second(ac_one_second),
          .key(ac_key_code),
//          .set_alarm(1'b0), // on the spec but not used; a key (*) used for set alarm
//          .set_time(1'b0),  // on the spec but not used; a key (-) used for set time
          
          /* outputs */
          .out_key_buffer(ac_key_buffer),
          .load_alarm(ac_load_alarm),
          .show_alarm(ac_show_alarm),
//          .alc_shift(ac_shift),
          .load_new_time(ac_load_new_time),
          .out_show_keyboard(ac_show_keyboard),

          .debug_state_out(alc_state),
          .debug_seconds_out(alc_seconds_time)
       );

//    assign kbd_reset = reset | ac_load_new_time | ac_load_alarm;

//    assign PIO[84] = ac_shift;
    assign PIO[84] = ac_load_new_time;
    assign PIO[85] = ac_show_keyboard;
    assign PIO[86] = ac_load_alarm;
    assign PIO[87] = ac_one_second;

    assign PIO[83:76] = { alc_seconds_time[3:0], alc_state } ;
//    assign PIO[83:76] = { ac_key_code[7:4], alc_state } ;

    /*
     *  AL_Clk_Counter  
     */
    wire [15:0] ac_current_time;

    al_clk_counter run_al_clk_counter
        ( .clk(MCLK),
          .reset(reset),
          .one_minute(ac_one_minute),
          .time_in(ac_key_buffer),
          .load_new_time(ac_load_new_time),

          /* outputs */
          .current_time_out(ac_current_time)
        );


    /*
     * Alarm Register
     */
    wire [15:0] curr_alarm_time;

    AL_Reg run_al_reg
        (.clk(MCLK),
         .reset(reset),
         .new_alarm_time(ac_key_buffer),
         .load_alarm(ac_load_alarm),

         /* output */
         .alarm_time(curr_alarm_time) );

    /*
     * Display Driver
     *
     */

    wire [15:0] ac_disp_drvr_output;

    DISP_DRVR run_disp_drvr
        (.reset(reset),
         .one_minute(ac_one_minute),
         .do_snooze(ac_snooze_button),
         .stop_alarm(ac_alarm_off_button),
         .alarm_time(curr_alarm_time),
         .current_time(ac_current_time),
         .show_alarm(ac_show_alarm),

         /* outputs */
         .display( ac_disp_drvr_output ),
         .sound_alarm(Led[0]) );

    assign Led[5:1] = 0;
    assign Led[7] = ac_one_second_level;
    assign Led[6] = ac_one_minute_level;

//    assign ac_7seg_input = ac_key_buffer;
    assign ac_7seg_input = ac_show_keyboard ? ac_key_buffer : ac_disp_drvr_output;

`ifdef SIMULATION
    initial
    begin
        $display("Hello, world");
        $dumpfile("alarm_clock.vcd");
        $dumpvars(0,alarm_clock);

        $monitor( "%d 7segin=%x key=%x keybuffer=%x", $time, 
                ac_7seg_input, ac_key_code, ac_key_buffer );

        # 10000000;
    end
`endif

endmodule


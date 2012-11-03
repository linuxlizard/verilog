`timescale 1 ns / 10 ps

module alarm_clock 
    ( input MCLK,
      input [7:0] sw,
      input [3:0] btn,

      inout PS2C,
      inout PS2D,

      output [7:0] Led,
      output [6:0] seg,
      output [3:0] an,
      output dp );

    wire [6:0] ac_seg;
    wire [3:0] ac_an;
    wire ac_dp;

    wire fast_mode;  /* sw0 */
    wire reset; /* sw7 */

    wire snooze;
    wire alarm_off;

    assign fast_mode = sw[0];
    assign reset = sw[7];
    
    /*
     * Edge to Pulse Snooze and Alarm Off
     */
    edge_to_pulse snooze_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[0]),
         .pulse_out(snooze));
    edge_to_pulse alarm_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[0]),
         .pulse_out(alarm_off));

    /*
     *  FREQ_DIV to 256Hz
     */

    wire clk256;

`ifdef SIMULATION
    localparam clock_div = 1;  /* counts 0,1,0,1,0,1,0,1,... */
`else
//    localparam clock_div = 195312;  // 50Mhz -> 256Hz
    localparam clock_div = 97656;  // 25Mhz -> 256Hz
`endif

    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(reset),
         .clk256(clk256) );

    /*
     *  TIME_GEN
     */
    wire ac_one_second;
    wire ac_one_minute;

    TIME_GEN run_time_gen
        (.clk256(clk256),
         .reset(reset),
         .fast_mode(fast_mode),
         .one_second(ac_one_second),
         .one_minute(ac_one_minute) );

    /* 
     *  Seven Segment Display 
     */

//    reg [3:0] bcd_ms_hour;
//    reg [3:0] bcd_ls_hour;
//    reg [3:0] bcd_ms_min;
//    reg [3:0] bcd_ls_min;

    reg [15:0] ac_display_input;

//    assign Led = {ac_display_input[7:0]};

`ifdef SIMULATION
    stub_digits_to_7seg run_digits_to_7seg 
`else
    hex_to_7seg run_digits_to_7seg 
`endif
        ( .rst(reset),
          .mclk(MCLK),
          .word_in( ac_display_input ),
//          .word_in( {bcd_ms_hour,bcd_ls_hour,bcd_ms_min,bcd_ls_min} ),
          .display_mask_in(4'b1111),
          .seg(ac_seg),
          .an(ac_an),
          .dp(ac_dp) );

    assign seg = ac_seg;
    assign an = ac_an;
    assign dp = ac_dp;

    /*
     *   KBD_IF 
     */
    wire ac_shift;
    wire [7:0] ac_key_code;
    wire [15:0] ac_key_buffer;
//    wire wire_set_alarm;
//    wire wire_set_time;

    kbd_if run_kbd_if 
        ( .clk256(clk256),
          .reset(reset),
          .kbd_shift(ac_shift),

          .PS2C(PS2C),
          .PS2D(PS2D),

          /* outputs */
          .key_buffer(ac_key_buffer),
          .key(ac_key_code)
//          .set_alarm(wire_set_alarm),
//          .set_time(wire_set_time) 
        );

    /*
     *  AL_Controller
     */

    wire ac_load_alarm;
    wire ac_show_alarm;
    wire ac_load_new_time;

    AL_Controller run_al_controller
        ( .clk256(clk256),
//          .reset(reset),
          .one_second(ac_one_second),
          .key(ac_key_code),
//          .set_alarm(1'b0), // on the spec but not used; a key (*) used for set alarm
//          .set_time(1'b0),  // on the spec but not used; a key (-) used for set time
          
          /* outputs */
          .load_alarm(ac_load_alarm),
          .show_alarm(ac_show_alarm),
          .alc_shift(ac_shift),
          .load_new_time(ac_load_new_time)
       );

    /*
     *  AL_Clk_Counter  
     */
    wire [15:0] ac_time_in;
    wire [15:0] ac_current_time;

    al_clk_counter run_al_clk_counter
        ( .clk256(clk256),
          .reset(reset),
          .one_minute(ac_one_minute),
          .time_in(ac_time_in),
          .load_new_time(ac_load_new_time),

          /* outputs */
          .current_time_out(ac_current_time)
        );


    /*
     * Alarm Register
     */
    wire [15:0] curr_alarm_time;

    AL_Reg run_al_reg
        (.clk256(clk256),
         .reset(reset),
         .new_alarm_time(ac_key_buffer),
         .load_alarm(ac_load_alarm),

         /* output */
         .alarm_time(curr_alarm_time) );


    reg [7:0] int_led;

    assign Led = int_led;

    always @(posedge(reset),posedge(MCLK))
    begin
        if( reset ) 
        begin
            ac_display_input <= ac_current_time;
        end
        else
        begin
            if( ac_key_buffer != 0 ) 
            begin
                int_led <= 8'b00000001;
                ac_display_input <= ac_key_buffer;
            end
            else if( ac_show_alarm )
            begin
                int_led <= 8'b00000010;
                ac_display_input <= curr_alarm_time;
            end
            else 
            begin
                int_led <= 8'b00000100;
                ac_display_input <= ac_current_time;
            end
        end
    end

endmodule


//-- Top Alarm Clock Controller.
//--
//-- ECE 4/530 Fall 2012
//--
//-- David Poole 27-Oct-2012
//-- 
//

`timescale 1 ns / 10 ps

`include "keycodes.vh"

module AL_Controller
    ( input  clk,
//      input  reset,
      input  one_second,
      input [7:0] key,
//      input set_alarm,
//      input set_time,

      output  reg load_alarm,
      output  reg show_alarm,
      output  reg alc_shift,
      output  reg load_new_time,
      output reg show_keyboard
    );

`define STATE_SHOW_TIME     0
`define STATE_KEY_STORE     1
`define STATE_KEY_HOLD      2
`define STATE_KEY_RELEASE_FINISH    3
`define STATE_KEY_ENTRY     4
`define STATE_SET_ALARM_TIME    5
`define STATE_SET_CURRENT_TIME  6
`define STATE_SHOW_ALARM    7
`define STATE_KEY_SHOW_ALARM_RELEASE 8

    reg [3:0] curr_state=`STATE_SHOW_TIME;
    reg [3:0] next_state=`STATE_SHOW_TIME;

//    reg [7:0] curr_key;

    always @(posedge(clk))
    begin
        curr_state <= next_state;
    end

    reg [7:0] seconds_timeout=0;

    always @(curr_state,key,one_second) 
    begin
        if( one_second )
            if( seconds_timeout > 0 )
                seconds_timeout <= seconds_timeout - 1;

        case( curr_state )
            `STATE_SHOW_TIME :
            begin
                load_alarm <= 0;
                show_alarm <= 0;
                show_keyboard <= 0;
                alc_shift <= 0;
                load_new_time <= 0;
                if( key==`KP_STAR ) 
                    next_state <= `STATE_SHOW_ALARM;
                else if( key==`KP_0 || 
                         key==`KP_1 || 
                         key==`KP_2 || 
                         key==`KP_3 || 
                         key==`KP_4 || 
                         key==`KP_5 || 
                         key==`KP_6 || 
                         key==`KP_7 || 
                         key==`KP_8 || 
                         key==`KP_9  ) 
                begin
                    show_keyboard <= 1;
                    next_state <= `STATE_KEY_STORE;
                end
            end

            `STATE_KEY_STORE :
            begin
                alc_shift <= 1;
                next_state <= `STATE_KEY_HOLD;
            end

            `STATE_KEY_HOLD :
            begin
                alc_shift <= 0;
                if( key==`KP_KEY_RELEASED )
                    next_state <= `STATE_KEY_RELEASE_FINISH;
            end

            `STATE_KEY_RELEASE_FINISH :
            begin
                // after the key release keycode, we will get another keycode
                // indicating which key was released
                if( key==`KP_INVALID ) 
                begin
                    seconds_timeout <= 10;
                    next_state <= `STATE_KEY_ENTRY;
                end
            end

            `STATE_KEY_ENTRY :
            begin
                if( seconds_timeout==0 ) 
                    // 10 seconds have elapsed; abandon operation and go back
                    // to display
                    next_state <= `STATE_SHOW_TIME;
                else if( key==`KP_STAR ) 
                    next_state <= `STATE_SET_ALARM_TIME;
                else if( key==`KP_MINUS ) 
                    next_state <= `STATE_SET_CURRENT_TIME;
                else if( key==`KP_0 || 
                         key==`KP_1 || 
                         key==`KP_2 || 
                         key==`KP_3 || 
                         key==`KP_4 || 
                         key==`KP_5 || 
                         key==`KP_6 || 
                         key==`KP_7 || 
                         key==`KP_8 || 
                         key==`KP_9  ) 
                begin
                    next_state <= `STATE_KEY_STORE;
                end
            end

            `STATE_SET_ALARM_TIME :
            begin
                load_alarm <= 1;
                next_state <= `STATE_SHOW_TIME;
            end

            `STATE_SET_CURRENT_TIME :
            begin
                load_new_time <= 1;
                next_state <= `STATE_SHOW_TIME;
            end

            `STATE_SHOW_ALARM :
            begin
                // stay here showing the alarm as long as the key is pressed
                show_alarm <= 1;
                show_keyboard <= 0;
                if( key==`KP_KEY_RELEASED )
                    next_state <= `STATE_KEY_SHOW_ALARM_RELEASE;
            end

            `STATE_KEY_SHOW_ALARM_RELEASE :
            begin
                // after the key release keycode, we will get another keycode
                // indicating which key was released. Eat that keycod here.
                if( key==`KP_INVALID ) 
                    next_state <= `STATE_SHOW_TIME;
            end

            default :
            begin
                load_alarm <= 0;
                show_alarm <= 0;
                show_keyboard <= 0;
                alc_shift <= 0;
                load_new_time <= 0;
                next_state <= `STATE_SHOW_TIME;
            end
        endcase
    end



endmodule


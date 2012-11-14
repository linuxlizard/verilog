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
      input  reset,
      input  one_second,
      input [7:0] key,
//      input set_alarm,
//      input set_time,

      output wire [15:0] out_key_buffer, // BCD value
      output  reg load_alarm,
      output  reg show_alarm,
//      output  reg alc_shift,
      output  reg load_new_time,
      output wire out_show_keyboard,

      output [3:0] debug_state_out,
      output [7:0] debug_seconds_out
    );

    reg [15:0] curr_key_buffer, key_buffer;
    assign out_key_buffer = curr_key_buffer;

    reg show_keyboard;
    assign out_show_keyboard = show_keyboard;

//    key_buffer_register Register
//        (.clk(clk),
//         .load(key_buffer_load),
//         .reset(reset),
//         .q(key_buffer),
//         .d(new_key_buffer) );

    
//`define STATE_SHOW_TIME     0
//`define STATE_KEY_STORE     1
//`define STATE_KEY_HOLD      2
//`define STATE_KEY_RELEASE_FINISH    3
//`define STATE_KEY_ENTRY     4
//`define STATE_SET_ALARM_TIME    5
//`define STATE_SET_CURRENT_TIME  6
//`define STATE_SHOW_ALARM    7
//`define STATE_KEY_SHOW_ALARM_RELEASE 8
parameter STATE_SHOW_TIME     = 4'd0;
parameter STATE_KEY_STORE     = 4'd1;
parameter STATE_KEY_HOLD      = 4'd2;
parameter STATE_KEY_RELEASE_FINISH    = 4'd3;
parameter STATE_KEY_ENTRY     = 4'd4;
parameter STATE_SET_ALARM_TIME    = 4'd5;
parameter STATE_SET_CURRENT_TIME  = 4'd6;
parameter STATE_SHOW_ALARM    = 4'd7;
parameter STATE_KEY_SHOW_ALARM_RELEASE = 4'd8;

    reg [3:0] curr_state;
    reg [3:0] next_state;

    assign debug_state_out = curr_state;

//    reg [7:0] curr_key;

    reg [7:0] seconds_timeout;
    reg [7:0] curr_seconds_timeout;

    assign debug_seconds_out = curr_seconds_timeout;

    always @(posedge(reset),posedge(clk))
    begin
        if( reset ) 
        begin
            curr_state <= STATE_SHOW_TIME;
            curr_key_buffer <= 16'h0000;
            curr_seconds_timeout <= 8'd0;
        end
        else
        begin
            curr_state <= next_state;
            curr_key_buffer <= key_buffer;
            curr_seconds_timeout <= seconds_timeout;
        end
    end

    always @( curr_state, key )
    begin

        key_buffer <= curr_key_buffer;
        load_alarm <= 1'b0;
        show_alarm <= 1'b0;
        load_new_time <= 1'b0;
        next_state <= curr_state;
        show_keyboard <= 1'b0;
        seconds_timeout <= curr_seconds_timeout;

        if( one_second ) begin
            if( curr_seconds_timeout > 8'd0 ) begin
                seconds_timeout <= curr_seconds_timeout - 8'd1;
            end
        end

        case( curr_state )
            STATE_SHOW_TIME :
            begin
//                show_keyboard <= 1'b0;
//                alc_shift <= 0;
                key_buffer <= 16'h0000;
                if( key==`KP_STAR ) begin
                    next_state <= STATE_SHOW_ALARM;
                end 
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
                    show_keyboard <= 1'b1;
                    next_state <= STATE_KEY_STORE;
                end
                else begin
                    show_keyboard <= 1'b0;
                    next_state <= STATE_SHOW_TIME;
                end
            end

            STATE_KEY_STORE :
            begin
//                alc_shift <= 1;
                /* Copy/paste. Brute Force. */
                case( key )
                    `KP_0 : key_buffer <= {curr_key_buffer[11:0],`KP_0_BCD}; 
                    `KP_1 : key_buffer <= {curr_key_buffer[11:0],`KP_1_BCD}; 
                    `KP_2 : key_buffer <= {curr_key_buffer[11:0],`KP_2_BCD}; 
                    `KP_3 : key_buffer <= {curr_key_buffer[11:0],`KP_3_BCD}; 
                    `KP_4 : key_buffer <= {curr_key_buffer[11:0],`KP_4_BCD}; 
                    `KP_5 : key_buffer <= {curr_key_buffer[11:0],`KP_5_BCD}; 
                    `KP_6 : key_buffer <= {curr_key_buffer[11:0],`KP_6_BCD}; 
                    `KP_7 : key_buffer <= {curr_key_buffer[11:0],`KP_7_BCD}; 
                    `KP_8 : key_buffer <= {curr_key_buffer[11:0],`KP_8_BCD}; 
                    `KP_9 : key_buffer <= {curr_key_buffer[11:0],`KP_9_BCD}; 
                    default : key_buffer <= {key_buffer[11:0], 4'hf}; 
                endcase

//                case( key )
//                    `KP_0 : key_buffer <= 16'h0000;
//                    `KP_1 : key_buffer <= 16'h1111;
//                    `KP_2 : key_buffer <= 16'h2222;
//                    `KP_3 : key_buffer <= 16'h3333;
//                    `KP_4 : key_buffer <= 16'h4444;
//                    `KP_5 : key_buffer <= 16'h5555;
//                    `KP_6 : key_buffer <= 16'h6666;
//                    `KP_7 : key_buffer <= 16'h7777;
//                    `KP_8 : key_buffer <= 16'h8888;
//                    `KP_9 : key_buffer <= 16'h9999;
//                    default : key_buffer <= 16'haaaa;
//                endcase

                next_state <= STATE_KEY_HOLD;
                show_keyboard <= 1'b1;
            end

            STATE_KEY_HOLD :
            begin
//                alc_shift <= 0;
                if( key==`KP_KEY_RELEASED )
                    next_state <= STATE_KEY_RELEASE_FINISH;
                else 
                    next_state <= STATE_KEY_HOLD;
                show_keyboard <= 1'b1;
            end

            STATE_KEY_RELEASE_FINISH :
            begin
                // after the key release keycode, we will get another keycode
                // indicating which key was released
                if( key==`KP_INVALID ) 
                begin
                    seconds_timeout <= 8'd10;
                    next_state <= STATE_KEY_ENTRY;
                end
                else begin
                    next_state <= STATE_KEY_RELEASE_FINISH;
                end
                show_keyboard <= 1'b1;
            end

            STATE_KEY_ENTRY :
            begin
                if( seconds_timeout==8'd0 ) 
                    // 10 seconds have elapsed; abandon operation and go back
                    // to display
                    next_state <= STATE_SHOW_TIME;
                else if( key==`KP_STAR ) 
                    next_state <= STATE_SET_ALARM_TIME;
                else if( key==`KP_MINUS ) 
                    next_state <= STATE_SET_CURRENT_TIME;
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
                    next_state <= STATE_KEY_STORE;
                end
                else begin
                    next_state <= STATE_KEY_ENTRY;
                end
                show_keyboard <= 1'b1;
            end

            STATE_SET_ALARM_TIME :
            begin
                load_alarm <= 1'b1;
                next_state <= STATE_SHOW_TIME;
                show_keyboard <= 1'b1;
            end

            STATE_SET_CURRENT_TIME :
            begin
                load_new_time <= 1'b1;
                next_state <= STATE_SHOW_TIME;
                show_keyboard <= 1'b1;
            end

            STATE_SHOW_ALARM :
            begin
                // stay here showing'b1 the alarm as long as the key is pressed
                show_alarm <= 1'b1;
                show_keyboard <= 1'b0;
                if( key==`KP_KEY_RELEASED )
                    next_state <= STATE_KEY_SHOW_ALARM_RELEASE;
            end

            STATE_KEY_SHOW_ALARM_RELEASE :
            begin
                // after the key release keycode, we will get another keycode
                // indicating which key was released. Eat that keycode here.
                if( key==`KP_INVALID ) 
                    next_state <= STATE_SHOW_TIME;
                show_keyboard <= 1'b1;
            end

            default :
            begin
                load_alarm <= 1'b0;
                show_alarm <= 1'b0;
                show_keyboard <= 1'b0;
                load_new_time <= 1'b0;
                next_state <= STATE_SHOW_TIME;
            end
        endcase
//    end /* if reset */
    end

endmodule


// ECE 4/530 Fall 2012
//
// David Poole 01-Nov-2012
//
// KBD Interface Test Bench
//

`timescale 1 ns / 10 ps

`include "keycodes.vh"

module kbd_if
    ( input clk256,
      input reset,
      input kbd_shift,

      inout PS2C,
      inout PS2D,

      output reg [15:0] key_buffer, // BCD value
      output reg [7:0] key // actual key codes
//      output reg set_alarm, // (ignored) handled in AL_Controller
//      output reg set_time   // (ignored) handled in AL_Controller
    );

    wire [7:0] kbd_key_code;
//    reg [15:0] kbd_key_buffer;

//    reg [7:0 ] last_key_pressed;

    PS2_Keyboard ps2kbd
        (.ck(clk256),
         .PS2C(PS2C),
         .PS2D(PS2D),
         .ps2_key_code(kbd_key_code) );

    always @(posedge clk256,posedge reset)
    begin
        if( reset ) 
        begin
            key <= 0;
            key_buffer <= 0;
//            set_time <= 0;
//            set_alarm <= 0;

//            kbd_key_buffer <= 0;
        end
        else if( kbd_shift == 1) 
        begin
            /* Copy/paste. Brute Force. */
            case( key )
                `KP_0 : 
                begin
//                    key_buffer <= {12'hfff,`KP_0_BCD}; 
                    key_buffer <= {key_buffer[11:0],`KP_0_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_0_BCD}; 
                end

                `KP_1 : 
                begin
//                    key_buffer <= {8'hef,`KP_1_BCD}; 
                    key_buffer <= {key_buffer[11:0],`KP_1_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_1_BCD}; 
                end

                `KP_2 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_2_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_2_BCD}; 
                end

                `KP_3 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_3_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_3_BCD}; 
                end

                `KP_4 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_4_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_4_BCD}; 
                end

                `KP_5 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_5_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_5_BCD}; 
                end

                `KP_6 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_6_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_6_BCD}; 
                end

                `KP_7 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_7_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_7_BCD}; 
                end

                `KP_8 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_8_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_8_BCD}; 
                end

                `KP_9 : 
                begin
                    key_buffer <= {key_buffer[11:0],`KP_9_BCD}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],`KP_9_BCD}; 
                end

                default : 
                begin
                    key_buffer <= {key_buffer[11:0], 4'hf}; 
//                    kbd_key_buffer <= {kbd_key_buffer[11:0],4'hf}; 
                end
            endcase
        end
        else 
        begin
            // filter incoming codes; only pass the values we're expecting
            case( kbd_key_code )
                `KP_0 : key <= `KP_0;   
                `KP_1 : key <= `KP_1;
                `KP_2 : key <= `KP_2;
                `KP_3 : key <= `KP_3;
                `KP_4 : key <= `KP_4;
                `KP_5 : key <= `KP_5;
                `KP_6 : key <= `KP_6;
                `KP_7 : key <= `KP_7;
                `KP_8 : key <= `KP_8;
                `KP_9 : key <= `KP_9;
                `KP_STAR : key <= `KP_STAR;
                `KP_MINUS : key <= `KP_MINUS;
                `KP_KEY_RELEASED : key <= `KP_KEY_RELEASED;
                default : key <= `KP_INVALID;
            endcase
        end
    end

endmodule


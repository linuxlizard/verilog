// ECE 4/530 Fall 2012
//
// David Poole 01-Nov-2012
//
// Fake PS2 Keyboard. Only returns a keycode. Ignores the PS2C, PS2D input.

`timescale 1 ns / 10 ps

`include "keycodes.vh"

module PS2_Keyboard 
    ( input ck,
      input PS2C,
      input PS2D,
      output reg [7:0] ps2_key_code );

    reg [31:0] key_counter = 0;

    always @(posedge(ck))
    begin
        key_counter <= key_counter + 1;         

        // run a simple set of keypresses in a loop
//        case( key_counter%20 )
//                // press
//                0,1,2 : ps2_key_code <= `KP_1; 
//                // release
//                3,4,5 : ps2_key_code <= `KP_KEY_RELEASED;
//                6,7,8 : ps2_key_code <= `KP_1; 
//
//                9,10,11 : ps2_key_code <= 0;
//
//                // press
//                5,6 : ps2_key_code <= `KP_2; 
//                // release
//                7 : ps2_key_code <= `KP_KEY_RELEASED;
//                8 : ps2_key_code <= `KP_2; 
//               10,11,12,13,14: ps2_key_code <= `KP_2;
//               15,16,17,18,19: ps2_key_code <= 0;
//                9,10: ps2_key_code <= `KP_3;
//               11,12: ps2_key_code <= 0;
//               13,14: ps2_key_code <= `KP_4;
//               15,16: ps2_key_code <= 0;
//            default : ps2_key_code <= 8'h00;
//        endcase
    end

`define KEY_DELAY 500
    initial
    begin
        /*
         *      Load Clock Time 12:34
         */
        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_1; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_1;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_2; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_2;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_3; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_3;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_4; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_4;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY

        /*  Push '-' to Load Current Time */
        $display( "push the - key to load current time" );
        # `KEY_DELAY
        ps2_key_code <= `KP_MINUS; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_MINUS;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 


        /* 
         * Load Alarm Time  12:35
         */
        # `KEY_DELAY
        ps2_key_code <= `KP_1; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_1;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_2; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_2;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_3; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_3;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        ps2_key_code <= `KP_5; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_5;

        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY


        /*  Push '*' to Load Alarm Time */
        $display( "push the * key to load alarm time" );
        # `KEY_DELAY
        ps2_key_code <= `KP_STAR; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_STAR;
        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 

        # `KEY_DELAY
        # `KEY_DELAY
        # `KEY_DELAY
        # `KEY_DELAY
        # `KEY_DELAY


        /* Push a number. Wait for timeout */
        # `KEY_DELAY
        ps2_key_code <= `KP_9; 
        # `KEY_DELAY
        ps2_key_code <= `KP_KEY_RELEASED;
        # `KEY_DELAY
        ps2_key_code <= `KP_9;
        # `KEY_DELAY
        ps2_key_code <= `KP_INVALID; 


        $display( "end of PS2 input" );
//        $finish;
//        # 10000000;
    end

endmodule


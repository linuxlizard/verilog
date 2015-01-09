// ECE 4/530 Fall 2012
//
// David Poole 01-Nov-2012
//
// KBD Interface Test Bench
//

`timescale 1 ns / 10 ps

`include "keycodes.vh"

module kbd_if
    ( input clk,
      input reset,

      input PS2C,
      input PS2D,

      output reg [7:0] key // actual key codes
    );

    wire [7:0] kbd_key_code;

    PS2_Keyboard ps2kbd
        (.ck(clk),
         .PS2C(PS2C),
         .PS2D(PS2D),
         .ps2_key_code(kbd_key_code) );

    always @(posedge clk,posedge reset)
    begin
        if( reset ) 
        begin
            key <= 0;
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


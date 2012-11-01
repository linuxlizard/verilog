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
      output reg [7:0] key_code_out );

    reg [31:0] key_counter = 0;

    always @(posedge(ck))
    begin
        key_counter <= key_counter + 1;         

        // run a simple set of keypresses in a loop
        case( key_counter%16 )
                0,1 : key_code_out <= `KP_1; 
                2,3 : key_code_out <= 0;
                4,5 : key_code_out <= `KP_2;
                6,7 : key_code_out <= 0;
                8,9 : key_code_out <= `KP_3;
               10,11: key_code_out <= 0;
               12,13: key_code_out <= `KP_4;
               14,15: key_code_out <= 0;
            default : key_code_out <= 0;
        endcase
    end

endmodule


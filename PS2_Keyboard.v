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
        case( key_counter%20 )
                // press
                0,1 : key_code_out <= `KP_1; 
                // release
                2 : key_code_out <= `KP_KEY_RELEASED;
                3 : key_code_out <= `KP_1; 

                4 : key_code_out <= 0;

                // press
                5,6 : key_code_out <= `KP_2; 
                // release
                7 : key_code_out <= `KP_KEY_RELEASED;
                8 : key_code_out <= `KP_2; 
//               10,11,12,13,14: key_code_out <= `KP_2;
//               15,16,17,18,19: key_code_out <= 0;
//                9,10: key_code_out <= `KP_3;
//               11,12: key_code_out <= 0;
//               13,14: key_code_out <= `KP_4;
//               15,16: key_code_out <= 0;
            default : key_code_out <= 8'h00;
        endcase
    end

endmodule


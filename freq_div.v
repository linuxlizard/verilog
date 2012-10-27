// ECE 4/530 Fall 2012
//
// David Poole 27-Oct-2012
//
// Frequency Divider


`timescale 1 ns / 10 ps

module FREQ_DIV
    // default to 50Mhz -> 256Hz as per homework assignment
    #( parameter divider=195312 )
    ( input wire clk,
      input wire reset,

      output wire clk256 );

    reg [31:0 ]current_value = 0;

    always @(posedge clk, posedge reset )
    begin
        if( reset ) 
        begin
            current_value <= 0;
            clk256 <= 1'b0;
        end
        else 
        begin
            current_value <= current_value+1;
        end
    end

endmodule


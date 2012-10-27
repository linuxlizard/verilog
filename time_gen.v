// ECE 4/530 Fall 2012
//
// David Poole 27-Oct-2012
//
// Generate wall clock seconds, minutes

`timescale 1 ns / 10 ps

module TIME_GEN
    ( input wire clk256,  // input clock should be 256Hz
      input wire reset,
      input wire fast_mode,  // when enabled, one_minute every second
      
      output wire one_second,
      output wire one_minute );

    reg int_one_second = 1'b0;
    reg int_one_minute = 1'b0;

    always @(posedge clk256, posedge reset )
    begin
        if( reset ) 
        begin
            int_one_second <= 1'b0;
            int_one_minute <= 1'b0;
        end
        else 
        begin
            
        end
    end

    assign one_second = int_one_second;
    assign one_minute = int_one_minute;

endmodule



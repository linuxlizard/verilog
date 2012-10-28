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

    reg [8:0] sec_counter = 9'b0;
    reg [5:0] min_counter = 6'b0;

    reg int_one_minute = 1'b0;

    // 256Hz means we can count once per clock in a 9-bit counter. The overflow
    // (9th) bit is our one second clock.
    always @(posedge clk256, posedge reset )
    begin
        if( reset ) 
        begin
            sec_counter <= 9'b0;
        end
        else 
        begin
            sec_counter <= sec_counter + 9'b000000001; 
        end
    end

    // Want to increment the minute counter every second. Rather than adding a
    // a compare on the sec_counter for 256*60, we will watch the 7th bit of
    // the sec_counter (256). When the 7th bit transitions (once a second) we
    // will udate our min_counter.
    always @(posedge reset, posedge sec_counter[7])
    begin
        if( reset ) 
        begin
            int_one_minute <= 1'b0;
            min_counter <= 6'b0;
        end
        else 
        begin
            min_counter <= min_counter + 1;
            if( min_counter >= 60 ) 
            begin
                min_counter <= 0;
                int_one_minute <= ~int_one_minute;
            end
        end
     end

    // if fast mode is enabled, minutes will become seconds and seconds will
    // become 1/4 seconds
    // TODO need to ask what to really do about seconds in fastmode
    assign one_second = fast_mode ? sec_counter[6] : sec_counter[8];
    assign one_minute = fast_mode ? sec_counter[8] : int_one_minute;

endmodule


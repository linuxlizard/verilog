// Register
// _FPGA Prototyping by Verilog Examples_ Cho 2008
//
// ECE4/530 Fall 2012
//
// David Poole 03-Nov-2012

`timescale 1 ns / 10 ps

module AL_Reg
    ( input wire clk,
      input wire reset,
      input wire [15:0] new_alarm_time,
      input wire load_alarm,
      output reg [15:0] alarm_time );

    always @(posedge clk, posedge reset )
    begin
        if( reset ) 
        begin
            alarm_time <= 0;
        end
        else if( load_alarm )
        begin
            alarm_time <= new_alarm_time;
        end
    end

endmodule



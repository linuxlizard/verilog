`timescale 1 ns / 10 ps

module digits_to_7seg( mclk, digit0_in, byte_in, seg, an, dp );

    input wire mclk;
    input wire [3:0] digit0_in;
    input wire [7:0] byte_in;

    output reg [6:0] seg;
    output reg [3:0] an;
    output reg dp;

    always @(posedge mclk)
    begin
        seg <= byte_in;
    end

endmodule


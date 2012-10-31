`timescale 1 ns / 10 ps

module stub_digits_to_7seg( input wire mclk,
                            input wire rst,
                            input wire [15:0] word_in,
                            input wire [7:0] display_mask_in,

                            output reg [6:0] seg,
                            output reg [3:0] an,
                            output reg dp );

    always @(posedge mclk)
    begin
        seg <= word_in;
        an <= 4'b1111;
        dp <= 1'b1;
    end

endmodule


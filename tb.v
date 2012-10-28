
`timescale 1 ns / 10 ps
`define PERIOD 10

module top_adder_accumulator( MCLK, Led, sw, seg, dp, an, btn );

    input MCLK; 
    input [7:0] sw;
    input [3:0] btn;

    output wire [7:0] Led;
    output wire [6:0] seg;
    output wire dp;
    output wire [3:0] an;

    reg int_reset;
    wire int_load;
    wire int_add;

    wire [6:0] int_seg;
    wire [3:0] int_an;
    wire int_dp;

    wire [7:0] adder_acc_data_out;

    AdderAccumulator run_adder_accumulator
        ( .load(int_load),
          .add(int_add),
          .reset(int_reset),
          .clock(MCLK),
          .data_in(sw),
          .output_sel(sw[1:0]),
          .data_out(adder_acc_data_out) );

    digits_to_7seg test_digits_to_7seg 
        ( .mclk(MCLK),
          .digit0_in(4'b0000),
          .byte_in(adder_acc_data_out),
          .seg(int_seg),
          .an(int_an),
          .dp(int_dp) );

    edge_to_pulse load_pulse
        (.clk(MCLK),
         .reset(int_reset),
         .edge_in(btn[1]),
         .pulse_out(int_load) );

    edge_to_pulse add_pulse
        (.clk(MCLK),
         .reset(int_reset),
         .edge_in(btn[2]),
         .pulse_out(int_add) );

          
    always @(posedge MCLK)
    begin
        int_reset <= btn[0];

//        seg = int_seg;
//        an = int_an;
//        dp = int_dp;

//        Led <= 8'd0;
    end

    assign seg = int_seg;
    assign an = int_an;
    assign dp = int_dp;

    assign Led = 8'd0;

endmodule


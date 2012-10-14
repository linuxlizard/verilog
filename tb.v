
`timescale 1 ns / 10 ps
`define PERIOD 10

module top_adder_accumulator( MCLK, Led, sw, seg, dp, an, btn );

    input MCLK; 
    input [7:0] sw;
    input [3:0] btn;

    output reg [7:0] Led;
    output reg [6:0] seg;
    output reg dp;
    output reg [3:0] an;

//    reg t_clk = 0;
//    reg t_reset = 1;
//    reg t_enable = 0;
//    reg [1:0] t_signal_in;
//    wire [1:0] t_signal_out;

//    top uut
//        (.Clock(t_clk),
//         .Reset(t_reset),
//         .Enable(t_enable),
//         .Signal_in(t_signal_in),
//         .Signal_out(t_signal_out) );

    reg int_load = 0;
    reg int_reset = 0;
    reg int_add = 0;

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
          
    always @(posedge MCLK)
    begin
        int_reset <= btn[0];
        int_load <= btn[1];
        int_add <= btn[2];

        seg <= int_seg;
        an <= int_an;
        dp <= int_dp;

        Led <= 8'd0;
    end


//    always
//    begin
//        #`PERIOD t_clk = ~t_clk;
//    end

//    initial
//    begin
//        $display("Hello, world");
//        t_reset = 1;
//        t_enable = 0;
//        t_signal_in = 0;
//        # 15
//
//        t_reset = 0;
//        # 10;
//
//        t_signal_in = 2'b11;
//        t_enable = 1;
//        # 10;
//
//        t_enable = 0;
//        # 10;
//    end

endmodule


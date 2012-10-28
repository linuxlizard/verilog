//-- Top Alarm Clock Controller.
//--
//-- ECE 4/530 Fall 2012
//--
//-- David Poole 27-Oct-2012
//-- 
//

`timescale 1 ns / 10 ps

/*
module AL_Controller
    ( input  MCLK,
      input  [7:0] sw,
      input  [3:0] btn,

      output  [7:0] Led,
      output  [6:0] seg,
      output  dp,
      output  [3:0] an
    );
*/

module AL_Controller ( MCLK, Led, sw, seg, dp, an, btn );

    input MCLK; 
    input [7:0] sw;
    input [3:0] btn;

    output wire [7:0] Led;
    output wire [6:0] seg;
    output wire dp;
    output wire [3:0] an;

    wire freq_div_out_time_gen_in;

    // internal signals
    reg int_fast_mode;
    wire int_one_second;
    wire int_one_minute;
    reg int_reset;

    wire [6:0] int_seg;
    wire [3:0] int_an;
    wire int_dp;

    reg [7:0] second_counter = 0;
    reg [7:0] minute_counter = 0;


`ifdef SIMULATION
    localparam clock_div = 2;  
`else
//    localparam clock_div = 195312;  // 50Mhz -> 256Hz
    localparam clock_div = 97656;  // 25Mhz -> 256Hz
`endif

    FREQ_DIV #(clock_div) run_freq_div
        (.clk(MCLK),
         .reset(int_reset),
         .clk256(freq_div_out_time_gen_in) );

    TIME_GEN run_time_gen
        (.clk256(freq_div_out_time_gen_in),
         .reset(int_reset),
         .fast_mode( int_fast_mode ),
         .one_second(int_one_second),
         .one_minute(int_one_minute) );

`ifdef SIMULATION
    stub_digits_to_7seg run_digits_to_7seg 
`else
    digits_to_7seg run_digits_to_7seg 
`endif
        ( .rst(int_reset),
          .mclk(MCLK),
          .word_in({ 8'h00,second_counter}),
          .seg(int_seg),
          .an(int_an),
          .dp(int_dp) );

    assign seg = int_seg;
    assign an = int_an;
    assign dp = int_dp;

//`define SIMULATION 1
`ifdef SIMULATION
    assign Led ={ minute_counter }; 
`else
    assign Led ={ minute_counter }; 
//    assign Led ={ int_one_minute,int_one_minute,int_one_minute,int_one_minute,
//                  int_one_second,int_one_second,int_one_second,int_one_second}; 
`endif

    always @(posedge MCLK)
    begin
        int_reset <= btn[0];
        int_fast_mode <= sw[1];
    end

    always @(posedge int_reset, posedge int_one_second )
    begin
        if( int_reset ) 
        begin
            second_counter <= 0;
        end
        else 
        begin
            if( second_counter <= 58 )
            begin
                second_counter <= second_counter+1;
            end
            else
            begin
                second_counter <= 0;
            end
        end
    end

    always @(posedge int_reset, posedge int_one_minute )
    begin
        if( int_reset ) 
        begin
            minute_counter <= 0;
        end
        else 
        begin
            if( minute_counter <= 58 )
            begin
                $display( "minute +1 = %d", minute_counter+1 );
                minute_counter <= minute_counter+1;
            end
            else
            begin
                $display( "minute reset" );
                minute_counter <= 0;
            end
        end
    end

endmodule


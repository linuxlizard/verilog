// BCD Clock  hours/minutes
//
// Add one minute. Ripple carry.
// Powered by Brute Force, Ignorance, and Caffeine.
//
// ECE 4/530 Fall 2012
//
// David Poole 28-Oct-2012
//

`timescale 1 ns / 10 ps

module bcd_clock( input clk, 
//                  input reset,
                  input add_one,
                  input [3:0] ms_hour,
                  input [3:0] ls_hour, 
                  input [3:0] ms_min,
                  input [3:0] ls_min,
                  
                  output reg [3:0] out_ms_hour,
                  output reg [3:0] out_ls_hour, 
                  output reg [3:0] out_ms_min,
                  output reg [3:0] out_ls_min 
                  
                  );

    reg [3:0] int_ms_hour=0;
    reg [3:0] int_ls_hour=0;
    reg [3:0] int_ms_min=0;
    reg [3:0] int_ls_min=0;

//    always @(posedge(reset), posedge(clk)) 
    always @(posedge(clk)) 
    begin
//        if( reset ) 
//        begin
//            out_ms_hour <= ms_hour;
//            out_ls_hour <= ls_hour;
//            out_ms_min <= ms_min;
//            out_ls_min <= ls_min;
////            out_ms_hour <= 0;
////            out_ls_hour <= 0;
////            out_ms_min <= 0;
////            out_ls_min <= 0;
//        end
//        else 
        begin
            out_ms_hour <= ms_hour;
            out_ls_hour <= ls_hour;
            out_ms_min <= ms_min;
            out_ls_min <= ls_min;

            if( add_one ) 
            begin
                int_ls_min <= int_ls_min+1;
                if( int_ls_min == 10 )
                begin
                    // ls_minutes overflows to ms_minutes 
                    int_ls_min <= 0;
                    int_ms_min <= int_ms_min+1;
                    if( int_ms_min == 6 )
                    begin
                        // minutes rolls over into hours
                        int_ms_min <= 0;
                        int_ls_hour <= int_ls_hour+1;
                        if( int_ls_hour==10 )
                        begin
                            // ls_hours overflows to ms_hours
                            int_ls_hour<=0;
                            int_ms_hour <= int_ms_hour + 1;
                        end
                        else if ( int_ms_hour==2 && int_ls_hour==4 ) 
                        begin
                            // rollover midnight to next day (00:00)
                            int_ls_hour <= 0;
                            int_ms_hour <= 0;
                        end
                    end
                end
            end
        end
    end /* yikes */

//    assign out_ms_hour = int_ms_hour;
//    assign out_ls_hour = int_ls_hour;
//    assign out_ms_min = int_ms_min;
//    assign out_ls_min = int_ls_min;

endmodule


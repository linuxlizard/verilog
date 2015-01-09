`timescale 1 ns / 10 ps

module al_clk_counter
    ( input clk,
      input reset,
      input one_minute,
      input [15:0] time_in,  /* time in BCD format */
      input load_new_time,

      output [15:0] current_time_out );

    reg [3:0] bcd_ms_hour_out;
    reg [3:0] bcd_ls_hour_out;
    reg [3:0] bcd_ms_min_out;
    reg [3:0] bcd_ls_min_out;

    task bcd_clock_minute; 
          input one_minute;
          input [3:0] ms_hour;
          input [3:0] ls_hour; 
          input [3:0] ms_min;
          input [3:0] ls_min;
          
          output reg [3:0] out_ms_hour;
          output reg [3:0] out_ls_hour; 
          output reg [3:0] out_ms_min;
          output reg [3:0] out_ls_min ;

          reg [3:0] int_ms_hour;
          reg [3:0] int_ls_hour; 
          reg [3:0] int_ms_min;
          reg [3:0] int_ls_min ;
    begin
            int_ms_hour = ms_hour;
            int_ls_hour = ls_hour;
            int_ms_min = ms_min;
            int_ls_min = ls_min;

            if( one_minute ) 
            begin
                int_ls_min = int_ls_min+1;
                if( int_ls_min == 10 )
                begin
                    // ls_minutes overflows to ms_minutes 
                    int_ls_min = 0;
                    int_ms_min = int_ms_min+1;
                    if( int_ms_min == 6 )
                    begin
                        // minutes rolls over into hours
                        int_ms_min = 0;
                        int_ls_hour = int_ls_hour+1;
                        if( int_ls_hour==10 )
                        begin
                            // ls_hours overflows to ms_hours
                            int_ls_hour=0;
                            int_ms_hour = int_ms_hour + 1;
                        end
                        else if ( int_ms_hour==2 && int_ls_hour==4 ) 
                        begin
                            // rollover midnight to next day (00:00)
                            int_ls_hour = 0;
                            int_ms_hour = 0;
                        end
                    end
                end
            end

            out_ms_hour = int_ms_hour;
            out_ls_hour = int_ls_hour;
            out_ms_min = int_ms_min;
            out_ls_min = int_ls_min;
    end
    endtask

    reg [15:0] int_current_time;

    assign current_time_out = int_current_time;

//    assign current_time_out = { bcd_ms_hour_out, bcd_ls_hour_out, 
//                                  bcd_ms_min_out, bcd_ls_min_out };

    always @(posedge(reset),posedge(clk))
    begin
        if( reset ) 
        begin
            bcd_clock_minute( 1'd0, 4'd1, 4'd2, 4'd0, 4'd0,
                              bcd_ms_hour_out,
                              bcd_ls_hour_out,
                              bcd_ms_min_out,
                              bcd_ls_min_out );
            int_current_time = { bcd_ms_hour_out, bcd_ls_hour_out, 
                                  bcd_ms_min_out, bcd_ls_min_out };
        end
        else if( load_new_time ) 
        begin
            bcd_clock_minute( 0, time_in[15:12],
                              time_in[11:8],
                              time_in[7:4],
                              time_in[3:0],

                              bcd_ms_hour_out,
                              bcd_ls_hour_out,
                              bcd_ms_min_out,
                              bcd_ls_min_out );
            int_current_time = { bcd_ms_hour_out, bcd_ls_hour_out, 
                                  bcd_ms_min_out, bcd_ls_min_out };
        end
        else if( one_minute ) 
        begin
            bcd_clock_minute( 1, int_current_time[15:12],
                              int_current_time[11:8],
                              int_current_time[7:4],
                              int_current_time[3:0],

                              bcd_ms_hour_out,
                              bcd_ls_hour_out,
                              bcd_ms_min_out,
                              bcd_ls_min_out );
            int_current_time = { bcd_ms_hour_out, bcd_ls_hour_out, 
                                  bcd_ms_min_out, bcd_ls_min_out };
        end
        else 
        begin
            int_current_time = { bcd_ms_hour_out, bcd_ls_hour_out, 
                                  bcd_ms_min_out, bcd_ls_min_out };
//            bcd_clock_minute( 0, time_in[15:12],
//                              time_in[11:8],
//                              time_in[7:4],
//                              time_in[3:0],
//
//                              bcd_ms_hour_out,
//                              bcd_ls_hour_out,
//                              bcd_ms_min_out,
//                              bcd_ls_min_out );
//            int_current_time <= 16'hffff;
//            int_current_time <= { bcd_ms_hour_out, bcd_ls_hour_out, 
//                                  bcd_ms_min_out, bcd_ls_min_out };
        end
    end
endmodule


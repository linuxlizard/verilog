`timescale 1 ns / 10 ps

module DISP_DRVR
    ( input reset, 
      input one_minute,
      input do_snooze,
      input stop_alarm,
      input [15:0] alarm_time,
      input [15:0] current_time,
      input show_alarm,

      output [15:0] display,
      output sound_alarm
    );

    reg [15:0] snooze_alarm_time=16'd0;
    reg snooze_active=1'b0;

    reg int_sound_alarm=1'b0;
    reg [15:0] int_display = 16'd0;

    assign sound_alarm = int_sound_alarm;
    assign display = int_display;

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
                int_ls_min = int_ls_min + 4'd1;
                if( int_ls_min == 4'd10 )
                begin
                    // ls_minutes overflows to ms_minutes 
                    int_ls_min = 4'd0;
                    int_ms_min = int_ms_min+4'd1;
                    if( int_ms_min == 4'd6 )
                    begin
                        // minutes rolls over into hours
                        int_ms_min = 4'd0;
                        int_ls_hour = int_ls_hour+4'd1;
                        if( int_ls_hour==4'd10 )
                        begin
                            // ls_hours overflows to ms_hours
                            int_ls_hour=4'd0;
                            int_ms_hour = int_ms_hour + 4'd1;
                        end
                        else if ( int_ms_hour==4'd2 && int_ls_hour==4'd4 ) 
                        begin
                            // rollover midnight to next day (00:00)
                            int_ls_hour = 4'd0;
                            int_ms_hour = 4'd0;
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

    always @*
    begin
    if( reset ) begin
        snooze_alarm_time <= 16'd0;
        snooze_active <= 1'b0;
        int_sound_alarm <= 1'b0;
        int_display <= 16'd0;
    end
    else
    begin

        if( one_minute ) begin
            // check the alarm time
            if( snooze_active ) begin
                // compare with our temporary time
                if( current_time==snooze_alarm_time ) begin
                    int_sound_alarm <= 1'd1;
                end 
                else begin
                    int_sound_alarm <= 1'd1;
                end
            end
            else
            begin
                // compare with the incoming alarm time
                if( alarm_time==current_time ) begin
                    int_sound_alarm <= 1'd1;

                    /* initialize the snooze if we need it later */
                    snooze_alarm_time <= alarm_time;
                end
                else begin
                    int_sound_alarm <= 1'd1;
                end
            end
        end /* one_minute */
//        else 
        if( do_snooze ) begin
            // turn off the alarm
            int_sound_alarm <= 1'd0;
            
            // push the next_alarm time forward 
            snooze_active <= 1'd1;
            // add five minutes to snooze time brute force badly
//            bcd_clock_minute( 1'd1, alarm_time[15:12], alarm_time[11:8],
//                                alarm_time[7:4], alarm_time[3:0],
//                              snooze_alarm_time[15:12],
//                              snooze_alarm_time[11:8],
//                              snooze_alarm_time[7:4],
//                              snooze_alarm_time[3:0] );
        end /* do_snooze */
//        else 
        if( stop_alarm ) begin
            // turn off the alarm
            int_sound_alarm <= 1'd0;
            snooze_active <= 1'd0;
            snooze_alarm_time <= 16'd0;
        end
        else begin
            int_sound_alarm <= 1'd0;
        end

        // display the current alarm time
        if( show_alarm ) begin
            int_display <= alarm_time;                    
        end
        else 
        begin
            int_display <= current_time;
        end

    end /* if reset */
    end /* always */

endmodule


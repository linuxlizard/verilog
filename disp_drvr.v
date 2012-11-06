`timescale 1 ns / 10 ps

module DISP_DRVR
    ( input one_minute,
      input snooze,
      input stop_alarm,
      input [15:0] alarm_time,
      input [15:0] current_time,
      input show_alarm,

      output [15:0] display,
      output sound_alarm
    );

    reg [15:0] snooze_alarm_time=0;
    reg snooze_active=0;

    reg int_sound_alarm=0;
    reg [15:0] int_display;

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

    always @(one_minute,snooze,stop_alarm,show_alarm,current_time)
    begin
        if( one_minute ) 
        begin
            // check the alarm time
            if( snooze_active ) 
            begin
                // compare with our temporary time
                if( current_time==snooze_alarm_time ) 
                begin
                    int_sound_alarm <= 1;
                end
            end
            else
            begin
                // compare with the incoming alarm time
                if( alarm_time==current_time )
                begin
                    int_sound_alarm <= 1;

                    /* initialize the snooze if we need it later */
                    snooze_alarm_time <= alarm_time;
                end
            end
        end
        else 

        if( snooze ) 
        begin
            // turn off the alarm
            int_sound_alarm <= 0;
            
            // push the next_alarm time forward 
            snooze_active <= 1;
            // add five minutes to snooze time brute force badly
            bcd_clock_minute( 1, alarm_time[15:12], alarm_time[11:8],
                                alarm_time[7:4], alarm_time[3:0],
                              snooze_alarm_time[15:12],
                              snooze_alarm_time[11:8],
                              snooze_alarm_time[7:4],
                              snooze_alarm_time[3:0] );
        end

        // turn off the alarm
        if( stop_alarm )
        begin
            int_sound_alarm <= 0;
            snooze_active <= 0;
            snooze_alarm_time <= 0;
        end

        // display the current alarm time
        if( show_alarm )
        begin
            int_display <= alarm_time;                    
        end
        else 
        begin
            int_display <= current_time;
        end

    end

endmodule


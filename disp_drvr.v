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

    reg int_sound_alarm;
    reg [15:0] int_display;

    assign sound_alarm = int_sound_alarm;
    assign display = int_display;

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
                end
            end
        end
        else 

        if( snooze ) 
        begin
            // push the next_alarm time forward 
            snooze_active <= 1;
            // TODO add five minutes to snooze time
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


`timescale 1 ns / 10 ps

module DISP_DRVR
    ( input clk,
      input reset, 
      input do_snooze,
      input stop_alarm,
      input [15:0] alarm_time,
      input [15:0] current_time,
      input show_alarm,

      output [15:0] display,
      output reg int_sound_alarm,

      output wire [7:0] debug_snooze,
      output [2:0] debug_state_out
    );

//    reg int_sound_alarm=1'b0;
//    reg [15:0] int_display = 16'd0;

//    assign sound_alarm = int_sound_alarm;
//    assign display = int_display;

    task bcd_clock_minute; 
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

            int_ls_min = int_ls_min+5;
            if( int_ls_min > 10 )
            begin
                // ls_minutes overflows to ms_minutes 
                int_ls_min = int_ls_min - 10;
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

            out_ms_hour = int_ms_hour;
            out_ls_hour = int_ls_hour;
            out_ms_min = int_ms_min;
            out_ls_min = int_ls_min;
    end
    endtask

    task foo_bcd_clock_minute; 
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

          reg [15:0] the_time;
    begin
            the_time = { ms_hour, ls_hour, ms_min, ls_min };

            int_ms_hour = ms_hour;
            int_ls_hour = ls_hour;
            int_ms_min = ms_min;
            int_ls_min = ls_min;

            if( the_time==16'h2359 ) begin
                // rollover midnight to next day (00:00)
                int_ms_hour = 4'd0;
                int_ls_hour = 4'd0;
                int_ms_min = 4'd0;
                int_ls_min = 4'd4;
            end
            else
            begin

                if( ls_min+4'd1 == 4'd10 )
                begin
                    // ls_minutes overflows to ms_minutes 
                    int_ls_min <= 4'd0;
                    if( ms_min+4'd1 == 4'd6 )
                    begin
                        // minutes rolls over into hours
                        int_ms_min <= 4'd0;
                        if( ls_hour+4'd1==4'd10 )
                        begin
                            // ls_hours overflows to ms_hours
                            int_ls_hour<=4'd0;
                            int_ms_hour <= ms_hour + 4'd1;
                        end
                        else begin
                            int_ls_hour <= ls_hour + 4'd1;
                        end
    //                    else if ( int_ms_hour==4'd2 && int_ls_hour==4'd4 ) 
    //                    begin
    //                        // rollover midnight to next day (00:00)
    //                        int_ls_hour <= 4'd0;
    //                        int_ms_hour <= 4'd0;
    //                    end
                    end
                    else begin
                        int_ms_min <= ms_min + 4'd1;
                    end
                end
                else begin
                    int_ls_min <= ls_min + 4'd1;
                end 
            end

            out_ms_hour <= int_ms_hour;
            out_ls_hour <= int_ls_hour;
            out_ms_min <= int_ms_min;
            out_ls_min <= int_ls_min;
    end
    endtask

//    assign int_sound_alarm = current_time==alarm_time ? 1'b1 : 1'b0;

    assign display = show_alarm==1'b1 ? alarm_time : current_time;

    parameter STATE_WAIT_FOR_ALARM = 3'd0;
    parameter STATE_ALARM_RINGING  = 3'd1;
    parameter STATE_ALARM_OFF      = 3'd2;
    parameter STATE_SNOOZE_ACTIVATED = 3'd3;
    parameter STATE_WAIT_FOR_SNOOZE  = 3'd4;

    reg [2:0] curr_state;
    reg [2:0] next_state;

    assign debug_state_out = curr_state;

    reg [15:0] curr_snooze, next_snooze;

    assign debug_snooze = { curr_snooze[7:4], curr_snooze[3:0] };

    always @(posedge(reset),posedge(clk))
    begin
        if( reset ) 
        begin
            curr_state <= STATE_WAIT_FOR_ALARM;
            curr_snooze <= 16'd0;
        end
        else
        begin
            curr_state <= next_state;
            curr_snooze <= next_snooze;
        end
    end

    always @*
    begin
//        next_snooze <= curr_snooze;
//        next_state <= curr_state;
//        int_sound_alarm <= 1'b0;

        case( curr_state ) 
            STATE_WAIT_FOR_ALARM :
            begin
                if( current_time==alarm_time ) begin
                    next_state = STATE_ALARM_RINGING;
                end
            end 

            STATE_ALARM_RINGING :
            begin
                int_sound_alarm = 1'b1;
                if( stop_alarm == 1'b1 ) begin
                    next_state = STATE_ALARM_OFF;
                end
                else 
                if( do_snooze ) begin
                    next_state = STATE_SNOOZE_ACTIVATED;
                end
            end 

            STATE_ALARM_OFF :
            begin
                int_sound_alarm = 1'b0;
                next_state = STATE_WAIT_FOR_ALARM;
            end 

            STATE_SNOOZE_ACTIVATED :
            begin
                int_sound_alarm = 1'b0;
                // add five minutes to snooze time brute force badly
                bcd_clock_minute( current_time[15:12], current_time[11:8],
                                    current_time[7:4], current_time[3:0],
                                  next_snooze[15:12], next_snooze[11:8],
                                  next_snooze[7:4], next_snooze[3:0] );
                next_state = STATE_WAIT_FOR_SNOOZE;
            end 

            STATE_WAIT_FOR_SNOOZE :
            begin
                if( current_time==curr_snooze ) begin
                    next_state = STATE_ALARM_RINGING;
                    next_snooze = 16'd0;
                end 
            end 

            default :
            begin
                next_state = STATE_WAIT_FOR_ALARM;
                next_snooze = 16'd0;
            end 

        endcase

    end

`ifdef DOES_NOT_WORK
    reg [15:0] snooze_alarm_time=16'd0;
    reg snooze_active;

    always @*
    begin
    if( reset == 1'b1 ) begin
        snooze_alarm_time <= 16'd0;
        snooze_active <= 1'b0;
        int_sound_alarm <= 1'b0;
//        int_display <= 16'd0;
    end
    else 
    if( one_minute == 1'b1 ) begin
            // check the alarm time
            if( snooze_active == 1'b1 ) begin
                // compare with our temporary time
                if( current_time==snooze_alarm_time ) begin
                    int_sound_alarm <= 1'd1;
                end 
                else begin
                    int_sound_alarm <= 1'd0;
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
                    int_sound_alarm <= 1'd0;
                end
            end
   end /* one_minute */
        else 
        if( do_snooze == 1'b1 ) begin
            // turn off the alarm
            int_sound_alarm <= 1'd0;
            
            // push the next_alarm time forward 
            snooze_active <= 1'd1;
            // add five minutes to snooze time brute force badly
            bcd_clock_minute( 1'd1, alarm_time[15:12], alarm_time[11:8],
                                alarm_time[7:4], alarm_time[3:0],
                              snooze_alarm_time[15:12],
                              snooze_alarm_time[11:8],
                              snooze_alarm_time[7:4],
                              snooze_alarm_time[3:0] );
        end /* do_snooze */
        else 
        if( stop_alarm == 1'b1 ) begin
            // turn off the alarm
            int_sound_alarm <= 1'd0;
            snooze_active <= 1'd0;
            snooze_alarm_time <= 16'd0;
        end
        else begin
            int_sound_alarm <= 1'd0;
        end

      // display the current alarm time
        if( show_alarm == 1'b1 ) begin
            int_display <= alarm_time;                    
        end
        else 
        begin
            int_display <= current_time;
        end

    end /* if reset */
    end /* always */
`endif

endmodule


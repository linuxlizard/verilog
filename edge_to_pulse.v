
`timescale 1 ns / 10 ps

module edge_to_pulse
    ( input wire clk,
      input wire reset,
      input wire edge_in,
      output reg pulse_out );

    localparam STATE_START = 2'b00;
    localparam STATE_FINISH = 2'b01;
    localparam STATE_TEMP = 2'b10;

    reg [1:0] current_state;
    reg [1:0] next_state;

    always @(posedge clk, posedge reset )
    begin
        if( reset ) 
            current_state <= STATE_START;
        else
            current_state <= next_state;
    end

    always @(current_state, edge_in )
    begin
        if( current_state == STATE_START )
            begin
                if( edge_in == 1'b1 ) 
                    next_state <= STATE_FINISH;
                else 
                    next_state <= STATE_START;
                pulse_out <= 1'b0;
            end
        else if( current_state ==  STATE_FINISH ) 
            begin
                next_state <= STATE_TEMP;
                pulse_out <= 1'b1;
            end
        else if( current_state==STATE_TEMP )
            begin
                if ( edge_in == 1'b1 )
                    next_state <= STATE_TEMP;
                else 
                    next_state <= STATE_START;
                pulse_out <= 1'b0;
            end
    end

endmodule


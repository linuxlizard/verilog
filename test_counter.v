// Test the Counter module.
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012

`timescale 1 ns / 10 ps

module counter_test;
    reg t_clk;
    reg t_reset;
    reg t_add;

    wire t_carry_out;
    wire [7:0] t_value_out;

    integer i;

    Counter counter1
        (.add(t_add),
         .reset(t_reset),
         .clock(t_clk),
         .carry_out(t_carry_out),
         .value_out(t_value_out));

    initial
    begin
        $display("Hello, world");
        t_clk <= 0;
        t_reset <= 1;
        t_add <= 0;
        # 20;

        t_reset <= 0;
        # 20;

        // cycle the add up/down to increment our counter
        t_add <= 1;
        # 20;
        t_add <= 0;
        # 20;
        t_add <= 1;
        # 20;
        t_add <= 0;
        # 20;
        $display("value=%d", t_value_out );

        // this test should roll over the 8-bit counter and carry should be set
        for( i=0 ; i<256 ; i=i+1 ) 
        begin
            t_add <= 1;
            # 5;
            t_add <= 0;
            # 5;
        end
        $display( "final=%d carry=%d", t_value_out, t_carry_out );
        
        t_reset <= 1;
        t_add <= 0;
        # 20;
        t_reset <= 0;
        for( i=0 ; i<10 ; i=i+1 ) 
        begin
            t_add <= 1;
            # 5;
            t_add <= 0;
            # 5;
        end
        $display( "final=%d", t_value_out );
    end

endmodule


/* Test the Naive Carry Lookahead Adder.
 *
 * ECE 4/530 Fall 2012
 *
 * David Poole 25-Sep-2012
 *
 */

module CarryLookaheadTest;
    reg [7:0] t_x;
    reg [7:0] t_y;
    reg t_c0;

    wire [7:0] t_output;
    wire t_carry_out;

    CarryLookaheadAdder cla
        (.X(t_x),
         .Y(t_y),
         .C0(t_c0),
         .sum(t_output),
         .carry_out(t_carry_out));

    integer i;
    
    initial
    begin
        t_x = 1;
        t_y = 2;
        t_c0 = 0;
# 5;
        $display(t_output);

        t_x = 1;
        t_y = 1<<3;
# 5;
        $display(t_output);

        t_x = 1;
        t_y = 1<<4;
# 5;
        $display(t_output);

        t_x = 1;
        t_y = 1;
# 5;
        $display(t_output);

        t_x = 2;
        t_y = 2;
# 5;
        $display(t_output);

        t_x = 4;
        t_y = 4;
# 5;
        $display(t_output);

        t_x = 8;
        t_y = 8;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 7;
        t_y = 7;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 15;
        t_y = 15;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 16;
        t_y = 16;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 32;
        t_y = 32;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 64;
        t_y = 64;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 127;
        t_y = 128;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 128;
        t_y = 128;
# 5;
        $display("%d %d", t_output, t_carry_out);

        t_x = 1;
        t_y = 0;
# 5;
        for( i=0 ; i<200 ; i=i+1 ) 
        begin
            t_y = t_output;
            #5;
        end
        $display("%d %d", t_output, t_carry_out);
    end

endmodule


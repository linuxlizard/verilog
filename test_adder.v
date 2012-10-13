// Test the Adder module.
//
// ECE 4/530 Fall 2012
//
// David Poole 23-Sep-2012

`timescale 1 ns / 10 ps

module adder_test;
    reg [7:0] t_operand_8;
    reg [15:0] t_operand_16; 

    wire [15:0] t_sum;

    Adder adder1
        (.new_operand(t_operand_8),
         .current_value(t_operand_16),
         .output_value(t_sum));

    initial
    begin
        $display("Adder Test");
        t_operand_8 = 8'h00;
        t_operand_16 = 16'h0000;
        # 20;
        $display( "%x", t_sum );

        t_operand_8 = 8'h01;
        t_operand_16 = 16'h0000;
        # 20;
        $display( "%x", t_sum );
    
        t_operand_8 = 8'h42;
        t_operand_16 = 16'h4200;
        # 20;
        $display( "%x", t_sum );
    
        t_operand_8 = 8'h42;
        t_operand_16 = 16'h4220;
        # 20;
        $display( "%x", t_sum );
        
        /* make sure the 8-bit to 16-bit overflow bit propagates */
        t_operand_8 = 8'hff;
        t_operand_16 = 16'hfe01;
        # 20;
        $display( "%x", t_sum );
        if( t_sum != 16'hff00 ) 
        begin
            $stop;
        end
      
        $display( "adder tests successful" );
    end

endmodule


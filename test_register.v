// Test register module.
//
// ECE4/530 Fall 2012
//
// David Poole 22-Sep-2012

`timescale 1 ns / 10 ps

`define PERIOD 10
`define HALF_PERIOD 5

//`define ASSERT_EQUALS(x,y) x = y

`define ASSERT_EQUALS(x,y) \
        repeat(1)\
        begin\
            if( (x) != (y) ) \
            begin\
                $write( "assert failed %d != %d\n", (x), (y) );\
                $finish_and_return(3);\
            end\
        end 

module register_test;
    parameter WIDTH=16;
    reg t_clk=0;
    reg t_load;
    reg t_reset;
    reg [WIDTH-1:0] t_data_in;
    wire [WIDTH-1:0] t_data_out;
    
    Register #(WIDTH) reg1
        (.clk(t_clk), 
         .load(t_load),
         .reset(t_reset),
         .d(t_data_in),
         .q(t_data_out));
         
    Register #(WIDTH) reg2
        (.clk(t_clk), 
         .load(t_load),
         .reset(t_reset),
         .d(t_data_in),
         .q(t_data_out));
         
    always 
    begin
        #`PERIOD t_clk = ~t_clk;
    end
        
//    initial
    always 
    begin
        $dumpfile("test_register.vcd");
        $dumpvars(0,register_test);

        $display("Hello, world");
        t_reset = 1;
        t_data_in = 0;
        t_load = 0;
        # 15;

        t_reset = 0;
        # 10;

        t_load = 1;
        t_data_in = 16'haa;
        # 10;
        
        /* set data to 0xffff so we can see it doesn't get pulled into 
         * the register
         */
        t_load = 0;
        t_data_in = 16'hffff;
        # 10;
//        `line 100;
//        $display( #line );
        `ASSERT_EQUALS(t_data_in,16'hfffe)

        t_data_in = 16'h4242;
        t_load = 1;
        # 10;
        
        /* set data to 0xffff so we can see it doesn't get pulled into 
         * the register
         */
        t_data_in = 16'hffff;
        t_load = 0;
        #10;
                
        #20;

        t_reset = 1;
        #10;
        
        $display("Goodbye, world");
        # 100 
        $finish(2);
    end

endmodule


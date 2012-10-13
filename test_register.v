// Test register module.
//
// ECE4/530 Fall 2012
//
// David Poole 22-Sep-2012

`timescale 1 ns / 10 ps

`define PERIOD 10
`define HALF_PERIOD 5

module register_test;
    parameter WIDTH=16;
    reg t_clk;
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
         
    initial
    begin
//        $dumpfile("register.vcd");
//        $dumpvars(0,register_test);

        $display("Hello, world");
        t_clk = 0;
        t_reset = 1;
        t_data_in = 0;
        t_load = 0;
        # 5;

        t_clk = 1;
        #5;

        t_reset = 0;
        # 5;

        t_clk = 0;
        #5;

        t_load = 1;
        t_data_in = 16'haa;
        # 5;
        
        t_clk = 1;
        # 5;

        /* set data to 0xffff so we can see it doesn't get pulled into 
         * the register
         */
        t_load = 0;
        t_data_in = 16'hffff;
        # 5;

        t_clk = 0;
        # 5;

        t_data_in = 16'h4242;
        t_load = 1;
        #5;
        
        t_clk = 1;
        #5;

        /* set data to 0xffff so we can see it doesn't get pulled into 
         * the register
         */
        t_data_in = 16'hffff;
        t_load = 0;
        #5;
                
        t_clk = 0;
        #5;

        #5;

        t_clk = 1;
        #5;

        #5;

        t_clk = 0;
        #5;
      
        t_reset = 1;
        #5;

        t_clk = 1;
        #5;

        #5;

        t_clk = 0;
        #5;

        $display("Goodbye, world");
    end

//    always @(*)
//    begin
//        #`PERIOD t_clk = ~t_clk;
//    end
        
endmodule


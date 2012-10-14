`timescale 1 ns / 10 ps
`define PERIOD 10
`define HALF_PERIOD 5

module test_edge_to_pulse;
    reg MCLK = 0;

    reg t_reset = 0;
    reg t_edge_in = 0;
    wire t_pulse_out;

    edge_to_pulse uut
        (.clk(MCLK),
         .reset(t_reset),
         .edge_in(t_edge_in),
         .pulse_out(t_pulse_out) );

    always
    begin
        #`HALF_PERIOD MCLK = ~MCLK;
    end

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_edge_to_pulse.vcd");
        $dumpvars(0,test_edge_to_pulse);
        #`HALF_PERIOD;
        t_reset <= 1'b1;
        #`PERIOD;

        t_reset <= 1'b0;
        #`PERIOD;

        t_edge_in <= 1'b1;
        #`PERIOD;

        #`PERIOD;
        #`PERIOD;
        t_edge_in <= 1'b0;
        #`PERIOD;
        #`PERIOD;
        #`PERIOD;

        # `HALF_PERIOD;
        t_edge_in <= 1'b1;
        # `HALF_PERIOD;
        t_edge_in <= 1'b0;
        # `HALF_PERIOD;

        #`PERIOD;
        
        t_reset <= 1'b1;
        #100;
        $finish;
    end

endmodule


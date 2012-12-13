// Test PIC
//
// David Poole
// ECE530 Fall 2012
//

`timescale 1 ns / 10 ps

`include "pic.vh"

module test_pic;

    parameter period  = 10;
    parameter half_period = 5;

    reg MCLK = 1'b0;

    // this project uses an nReset so start at zero (resetN enabled)
    reg resetN = 1'b0;

    wire [7:0] data_wire;
    reg [7:0] t_data = 8'hff;
    reg [1:0] t_select = `SEL_OCR;
    reg t_readwrite = `RW_READ;
    reg [7:0] t_intreq = 8'h00;
    reg t_intackN = 1'b1;
    wire t_int;
    reg [7:0] t_test= 8'h00;

    /* test/debug in simulation; change this number to track code location
     * during simulation
     */
    integer debug_num = 0;

    /* This is the clock */
    always
    begin
        #half_period MCLK = ~MCLK;
    end

    assign data_wire = t_data;

    pic run_pic
        (.clk(MCLK),
         .resetN(resetN),
         .data(data_wire),
         .select(t_select),
         .readwrite(t_readwrite),
         .intreq(t_intreq),
         .intackN(t_intackN),

         // output(s)
         .int_out(t_int));

    task test_registers;
    begin
        /* test simple register read/write interface via continuous assignment */
        t_test = 8'h01;
        t_data = 8'hzz;
        t_select = `SEL_OCR;
        t_readwrite = `RW_READ;
        # period;
        # period;

        t_test = 8'h02;
        t_select = `SEL_OCR;
        t_data = 8'haa;
        t_readwrite = `RW_WRITE;
        # period;

        t_test = 8'h03;
        t_data = 8'hzz;
        t_select = `SEL_IMR;
        t_readwrite = `RW_READ;
        # period;

        t_test = 8'h04;
        t_data = 8'hzz;
        t_select = `SEL_OCR;
        t_readwrite = `RW_READ;
        # period;

        t_test = 8'h05;
        t_data = 8'h22;
        t_select = `SEL_IMR;
        t_readwrite = `RW_WRITE;
        # period;

        t_test = 8'h03;
        t_data = 8'hzz;
        t_select = `SEL_IMR;
        t_readwrite = `RW_READ;
        # period;
    end
    endtask

    /*
     *  Interrupt Ack with no delay between edges
     */
    task quick_pulse_intackN;
    begin
        $display("pulsing intackN" );
        t_intackN = 1'b0;
        # period;
        t_intackN = 1'b1;
        # period;
    end
    endtask

    /* Run a test of a single interrupt. No register reads during the intacks.  */
    task test_single_interrupt;
    begin
        $display( "test_single_interrupt");
        t_intreq = 8'h04;
        # period;

        $display( "waiting for int=1" );
        wait(t_int==1'b1);
        $display( "got int=%x", t_int );

        /* pulse the ack line, drop the incoming interrupt */
        $display("pulsing intackN" );
        t_intreq = 8'h00;
        quick_pulse_intackN;

        /* wait several clocks (TODO read some registers here) */
        # period; # period; # period; # period;
        # period; # period; # period; # period;

        /* pulse the ack line again */
        $display("pulsing intackN" );
        quick_pulse_intackN;

        $display( "waiting for int=0" );
        wait(t_int==1'b0);
        # period;

        $display( "test_single_interrupt done");
    end
    endtask

    /* run a test with multiple simultaneous pending interrupts. No register
     * reads yet.
     */
    task test_multiple_interrupt;
    begin
        $display( "test_multiple_interrupt" );

        t_intreq = 8'h05;
        # period;

        $display( "waiting for int=1" );
        wait(t_int==1'b1);
        $display( "got int=%x", t_int );

        /* pulse the ack line */
        $display("pulsing intackN" );
        quick_pulse_intackN;

        /* wait several clocks (TODO read some registers here) */
        # period; # period; # period; # period;
        # period; # period; # period; # period;

        /* drop the 1st interrupt */
        t_intreq = 8'h04;

        /* pulse the ack line again */
        $display("pulsing intackN" );
        quick_pulse_intackN;

        /* now handle the 2nd interrupt we requested */
        $display( "handling second interrupt" );
        wait(t_int==1'b1);

        /* FIXME have to put some time between the acks */
        # period;
        # period;

        /* for now, just ack the 2nd interrupt */
        quick_pulse_intackN;
//        # period;
        t_intreq = 8'h00;
        quick_pulse_intackN;

        $display( "waiting for int=0" );
        wait(t_int==1'b0);

        $display( "test_multiple_interrupt done");
    end
    endtask

    /* Trigger an interrupt. Read registers between the ack pulses */
    task test_single_interrupt_with_read;
    begin
        $display( "write IMR" );
        t_test = 8'h01;
        t_data = 8'haa;
        t_select = `SEL_IMR;
        t_readwrite = `RW_WRITE;
        # period;
        $display( "read IMR back" );
        t_test = 8'h02;
        t_data = 8'hzz;
        t_select = `SEL_IMR;
        t_readwrite = `RW_READ;
        # period;

        $display( "test_single_interrupt_with_read");
        t_intreq = 8'h04;
        # period;

        $display( "waiting for int=1" );
        wait(t_int==1'b1);
        $display( "got int=%x", t_int );

        /* pulse the ack line, drop the incoming interrupt */
        $display("pulsing intackN" );
        t_intreq = 8'h00;
        quick_pulse_intackN;

        /* wait several clocks (TODO read some registers here) */
        # period; # period; # period; # period;
        # period; # period; # period; # period;

        $display("read irr regnum=%x", `SEL_IRR );
        t_test = 8'h05;
        t_data = 8'hzz;
        t_select = `SEL_IRR;
        t_readwrite = `RW_READ;
        # period;
        $display("read isr regnum=%x", `SEL_ISR );
        t_test = 8'h06;
        t_data = 8'hzz;
        t_select = `SEL_ISR;
        t_readwrite = `RW_READ;
        # period;
        t_test = 8'h07;

        # period; # period; # period; # period;
        # period; # period; # period; # period;

        /* pulse the ack line again */
        $display("pulsing intackN" );
        quick_pulse_intackN;

        $display( "waiting for int=0" );
        wait(t_int==1'b0);
        # period;

        $display( "test_single_interrupt done");
    end
    endtask

    initial
    begin
        $display("Hello, world");
        $dumpfile("test_pic.vcd");
        $dumpvars(0,test_pic);

        $monitor("%d int=%d data=%x", $time, t_int, data_wire );

        t_data = 8'hzz;
        # period;
        # period;

        resetN = 1'b1;
        debug_num = 1;
        # period;

//        debug_num = 10;
//        test_single_interrupt;

//        debug_num = 20;
//        test_multiple_interrupt;

        debug_num = 30;
        test_single_interrupt_with_read;
        
        # 1000;

        $display("goodbye!");
        $finish;
    end

endmodule


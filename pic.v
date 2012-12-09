// Project#2 Programmable Interrupt Controller (PIC)
//
// David Poole
// ECE 530 - Fall 2012

`timescale 1 ns / 10 ps

`include "pic.vh"

module pic
    ( input wire clk,
      input wire resetN,

      /* read/write register interface */
      inout wire [7:0] data,
      input wire [1:0] select,
      input wire readwrite,
      
      /* incoming interrupt request */
      input wire [7:0] intreq,

      /* ack the active interrupt */
      input wire intackN,

      /* high when there is an interrupt pending */
      output wire int_out );

    wire reset;

    wire ocr_wr;
    wire [7:0]ocr_data;

    wire imr_wr;
    wire [7:0]imr_data;

    reg irr_set;
    reg irr_clr;
    reg [7:0] irr_data_in;
    reg [7:0]irr_data;

    reg isr_set;
    reg isr_clr;
    reg [7:0] isr_data_in;
    reg [7:0]isr_data;

    /* spec says incoming reset signal is active low so flip it so it's
     * compatible with our register's reset
     */
    assign reset = ~resetN;

    Register #(8) OCR
        (.clk(clk),
         .load(ocr_wr),
         .reset(reset),
         .d(data),
         .q(ocr_data));
            
    Register #(8) IMR
        (.clk(clk),
         .load(imr_wr),
         .reset(reset),
         .d(data),
         .q(imr_data));

    /* 
     * IRR register -- set/clear individual bits 
     */
    always @(posedge clk, posedge reset)
    begin
        if( reset==1'b1 ) 
        begin
            irr_data <= 8'h00;
        end
        else if( irr_set==1'b1 )
        begin
            irr_data <= irr_data | irr_data_in;
        end
        else if( irr_clr==1'b1 ) 
        begin
            irr_data <= irr_data & (~irr_data_in);
        end
    end
    
    /*
     * ISR Register -- can set/clear individual bits
     */
    always @(posedge clk, posedge reset)
    begin
        if( reset==1'b1 ) 
        begin
            isr_data <= 8'h00;
        end
        else if( isr_set==1'b1 )
        begin
            isr_data <= isr_data | isr_data_in;
        end
        else if( isr_clr==1'b1 ) 
        begin
            isr_data <= isr_data & (~isr_data_in);
        end
    end

            
    /*
     * Register read/write interface
     */
    assign ocr_wr = select==`SEL_OCR ? ~readwrite : 1'b0;
    assign imr_wr = select==`SEL_IMR ? ~readwrite : 1'b0;
//    assign irr_wr = select==`SEL_IRR ? ~readwrite : 1'b0;
//    assign isr_wr = select==`SEL_ISR ? ~readwrite : 1'b0;

    /* XXX temp rewire */
    wire [7:0] foo_data;
    assign foo_data = readwrite==`RW_WRITE ? 8'bzzzzzzzz : 
                        (select==`SEL_OCR ? ocr_data :
                        (select==`SEL_IMR ? imr_data :
                        (select==`SEL_IRR ? irr_data :
                        (select==`SEL_ISR ? isr_data : 8'hee))));

    /* 
     * IRQ priority list 
     */
    reg [7:0] irq_priority_list [7:0];

    /* index of most recently serviced interrupt */
    reg [2:0] irq_priority_idx = 4'h0;
    `include "irq_list.vh"

    reg [7:0] next_data = 8'hzz;
    assign data = next_data;

    /*
     *  PIC State Machine
     */
    parameter STATE_RESET = 4'd0;
    parameter STATE_INIT = 4'd1;
    parameter STATE_WAIT_FOR_ACK_1_LOW = 4'd2;
    parameter STATE_WAIT_FOR_ACK_1_HIGH = 4'd3;
    parameter STATE_WAIT_FOR_SECOND_ACK = 4'd4;
    parameter STATE_DRIVE_DATA_POINTER = 4'd5;
    parameter STATE_CLEAR_IRR = 4'd6;

    reg [5:0] next_state;
    reg [5:0] curr_state;

    wire [5:0] debug_state;
    assign debug_state = curr_state;

    /* pending interrupt number */
    reg [2:0] irq_num;
    reg [2:0] next_irq_num;

    reg next_int;
    reg int;
    assign int_out = int;

    always @(posedge(reset),posedge(clk))
    begin
        if( reset ) 
        begin
            curr_state <= STATE_RESET;
            irq_num <= 3'b000;
            int <= 1'b0;
        end
        else
        begin
            curr_state <= next_state;
            irq_num <= next_irq_num;
            int <= next_int;
        end
    end

    /*
     * Interrupt control logic
     */
    always @(*)
    begin
        next_state <= curr_state;
        next_irq_num <= irq_num;

        irr_set <= 1'b0;
        irr_clr <= 1'b0;
        irr_data_in <= 8'h00;

        isr_set <= 1'b0;
        isr_clr <= 1'b0;
        isr_data_in <= 8'h00;

        next_int <= int;

        next_data <= 8'hZZ;

        case( curr_state ) 
            STATE_RESET  :
            begin
                $display("state_reset");
                next_state <= STATE_INIT;
                priority_list_init;
            end

            STATE_INIT  :
            begin
                $display( "state_init" );
                if( intreq != 8'h00 ) 
                begin
                    /* we have an incoming interrupt */
                    $display( "incoming interrupt" );

                    next_state <= STATE_WAIT_FOR_ACK_1_LOW;

                    /* write the incoming IRQ value to our IRR register */
                    irr_set <= 1'b1;
                    irr_data_in <= intreq;

                    /* raise the interrupt pending line */
                    next_int <= 1'b1;

                    /* find the highest priority interrupt to service */
                    priority_queue_dump;
                    next_irq_num <= find_irq( intreq );
                end
            end

            STATE_WAIT_FOR_ACK_1_LOW  :
            begin
                $display("waiting for ack_1 low");
                /* intackN line is default high; wait for CPU to drive it low */
                if( intackN==1'b0 ) 
                begin
                    next_state <= STATE_WAIT_FOR_ACK_1_HIGH;
                end
            end

            STATE_WAIT_FOR_ACK_1_HIGH  :
            begin
                $display("waiting for ack_1 high");
                /* clear the bit of the ISR we're going to handle */
                irr_clr <= 1'b1;
                irr_data_in <= 8'h01<<irq_num;

                /* allow the CPU to drive the bus */
                next_data <= 8'hZZ;

                /* set the bit of our chosen IRQ in the ISR register */
                isr_set <= 1'b1;
                isr_data_in <= 8'd1 << irq_num;

                if( intackN==1'b1 ) 
                begin
                    next_state <= STATE_WAIT_FOR_SECOND_ACK;
                end
            end

            STATE_WAIT_FOR_SECOND_ACK  :
            begin
                $display("wait for second ack");
                /* CPU can read registers while we're fiddling around waiting
                 * for the ack(s). That's why we set the data bus to 'Z' in the
                 * previous state. So the CPu can query registers. Not sure how
                 * I'm going to accomplish that yet...
                 */
                if( intackN==1'b0 )
                begin
                    next_state <= STATE_DRIVE_DATA_POINTER;
                end
            end

            STATE_DRIVE_DATA_POINTER  :
            begin
                $display("driving the vector onto the bus" );

                /* drive the interrupt vector onto the bus */
                next_data <= { 5'b10100, irq_num };

                /* now wait for cpu to drive the intackN back to 1 */
                if( intackN==1'b1 )
                begin
                    next_state <= STATE_CLEAR_IRR;
                end
            end

            STATE_CLEAR_IRR  :
            begin
                $display("clear irr" );
                next_state <= STATE_INIT;

                /* clear the IRQ bit from ISR register */
                isr_clr <= 1'b1;
                isr_data_in <= 1<<irq_num;

                /* release the data bus */
                next_data <= 8'hzz;
                priority_list_rotate( irq_num );
                priority_queue_dump;

                /* drop the interrupt pending line if there are no more pending
                 * interrupts
                 */
                if( irr_data==8'h00 )
                begin
                    next_int <= 1'b0;
                end
            end

            default : 
            begin
                next_state <= STATE_RESET;
            end

        endcase
    end
    
endmodule


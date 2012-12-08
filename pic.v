// Project#2 Programmable Interrupt Controller (PIC)
//
// David Poole
// ECE 530 - Fall 2012

`timescale 1 ns / 10 ps

`include "pic.vh"

module pic
    ( input wire clk,
      input wire reset,

      /* read/write register interface */
      inout wire [7:0] data,
      input wire [1:0] select,
      input wire readwrite,
      
      /* incoming interrupt request */
      input wire [7:0] intreq,

      /* ack the active interrupt */
      input wire intack,

      /* high when there is an interrupt pending */
      output reg int );

    wire n_reset;
//    reg [7:0]int_data;

    wire ocr_wr;
    wire [7:0]ocr_data;
//    reg [7:0] int_ocr_data;
//    assign ocr_data = int_ocr_data;

    wire imr_wr;
    wire [7:0]imr_data;
//    reg [7:0] int_imr_data;
//    assign imr_data = int_imr_data;

    wire irr_wr;
    wire [7:0]irr_data;
//    reg [7:0] int_irr_data;
//    assign irr_data = int_irr_data;

    wire isr_wr;
    wire [7:0]isr_data;
//    reg [7:0]int_isr_data;
//    assign isr_data = int_isr_data;

    /* spec says incoming reset signal is active low so flip it so it's
     * compatible with our register's reset
     */
    assign n_reset = ~reset;

    Register #(8) OCR
        (.clk(clk),
         .load(ocr_wr),
         .reset(n_reset),
         .d(data),
         .q(ocr_data));
            
    Register #(8) IMR
        (.clk(clk),
         .load(imr_wr),
         .reset(n_reset),
         .d(data),
         .q(imr_data));
            
    Register #(8) IRR
        (.clk(clk),
         .load(irr_wr),
         .reset(n_reset),
         .d(data),
         .q(irr_data));
            
    Register #(8) ISR
        (.clk(clk),
         .load(isr_wr),
         .reset(n_reset),
         .d(data),
         .q(isr_data));

//    assign data = int_data;

    assign ocr_wr = select==`SEL_OCR ? ~readwrite : 1'b0;
    assign imr_wr = select==`SEL_IMR ? ~readwrite : 1'b0;
    assign irr_wr = select==`SEL_IRR ? ~readwrite : 1'b0;
    assign isr_wr = select==`SEL_ISR ? ~readwrite : 1'b0;

//    assign data = readwrite==`RW_WRITE ? 8'bzzzzzzzz : 8'hee;
    assign data = readwrite==`RW_WRITE ? 8'bzzzzzzzz : 
                        (select==`SEL_OCR ? ocr_data :
                        (select==`SEL_IMR ? imr_data :
                        (select==`SEL_IRR ? irr_data :
                        (select==`SEL_ISR ? isr_data : 8'hee))));

//    always @(*)
//    begin
//        case( select ) 
//            `SEL_OCR : 
//                if( readwrite==`RW_READ ) 
//                begin
//                    int_data = int_ocr_data;
//                end
//                else
//                begin
//                    int_ocr_data = int_data;
//                end
//
//            `SEL_IMR : int_data = imr_data;
//            `SEL_IRR : int_data = irr_data;
//            `SEL_ISR : int_data = isr_data;
//        endcase
//    end

    always @(reset,clk)
    begin
        if( reset==1'b1 ) 
        begin
            int = 1'b0;
        end
        else
        begin
        end
        
//        if( readwrite==`RW_WRITE ) 
//        begin
//            data = 8'bzzzzzzzz;
//        end
//        else 
//        begin
//            case( select )
//                `SEL_OCR : data = ocr_data;
//                `SEL_IMR : data = imr_data;
//                `SEL_IRR : data = irr_data;
//                `SEL_ISR : data = isr_data;
//            endcase
//        end
    end
    
endmodule


// Project#2 Programmable Interrupt Controller (PIC)
//
// David Poole
// ECE 530 - Fall 2012

`timescale 1 ns / 10 ps

`include "pic.vh"

module pic
    ( input wire clk,
      input wire reset,
      inout wire [7:0] data,
      input wire [1:0] select,
      input wire readwrite,
      input wire [7:0] IR,
      input wire intack,
      output wire int );

    wire n_reset;
    wire [7:0]int_data;

    wire ocr_wr;
    wire [7:0]ocr_data;

    wire imr_wr;
    wire [7:0]imr_data;

    wire irr_wr;
    wire [7:0]irr_data;

    wire isr_wr;
    wire [7:0]isr_data;

    assign n_reset = ~reset;

    Register #(8) OCR
        (.clk(clk),
         .load(ocr_wr),
         .reset(n_reset),
         .d(int_data),
         .q(ocr_data));
            
    Register #(8) IMR
        (.clk(clk),
         .load(imr_wr),
         .reset(n_reset),
         .d(int_data),
         .q(imr_data));
            
    Register #(8) IRR
        (.clk(clk),
         .load(irr_wr),
         .reset(n_reset),
         .d(int_data),
         .q(irr_data));
            
    Register #(8) ISR
        (.clk(clk),
         .load(isr_wr),
         .reset(n_reset),
         .d(int_data),
         .q(isr_data));

    always @(readwrite)
    begin
        if( readwrite==RW_READ ) 
        begin
            case( select )
                SEL_OCR 

        else 
        begin
        end
    end
    
endmodule


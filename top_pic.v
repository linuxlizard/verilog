`timescale 1 ns / 10 ps

module top_pic 
    ( input MCLK,
      input [7:0] sw,
      input [3:0] btn,

      /* JA 1,2,3,4 (used with debugging) */
      output [87:72] PIO, 

      output [7:0] Led,
      output [6:0] seg,
      output [3:0] an,
      output dp );

    assign PIO = 16'h0000;

    wire resetN; /* BTN0 */
    assign resetN = ~btn[0];

    /* using BTN3 so it's far away from the reset button :-) */
    wire intackN;  /* BTN3 */
    assign intackN = ~btn[3];

    assign Led[1] = intackN;

    /* also create a regular reset for my previous components */
    wire reset;
    assign reset = ~resetN;

    /* SW[7:0] are IRQ */
    wire [7:0] intreq;
    assign intreq = sw;

    /* interrupt pending line */
    wire int;
    assign Led[0] = int;
     
    wire [7:0] data_wire;

    /* register interface */
    reg [1:0] register_select;
    reg register_readwrite;

    /*
     *  PIC Programmable Interrupt Controller
     */
    pic run_pic
        (.clk(MCLK),
         .resetN(resetN),
         .data(data_wire),
         .select(register_select),
         .readwrite(register_readwrite),
         .intreq(intreq),
         .intackN(intackN),

         // output(s)
         .int_out(int));

    /*
     * Display
     */
`ifdef SIMULATION
    stub_digits_to_7seg run_digits_to_7seg 
`else
    hex_to_7seg run_digits_to_7seg 
`endif
        ( .rst(reset),
          .mclk(MCLK),
//          .word_in( ac_key_buffer ),
          .word_in( 16'h1234 ),
          .display_mask_in(4'b1111),

          /* outputs */
          .seg(seg),
          .an(an),
          .dp(dp) );

//    edge_to_pulse snooze_button_edge_to_pulse
//        (.clk(MCLK),
//         .reset(reset),
//         .edge_in(btn[0]),
//         .pulse_out(ac_snooze_button));

endmodule


// Top Level PIC (Programmable Interrupt Controller)
//
//  ECE 530 Fall 2012
//
//  David Poole 
//  09-Dec-2012

`timescale 1 ns / 10 ps

`include "pic.vh"

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

    wire resetN; /* BTN0 */
    assign resetN = ~btn[0];

    /* also create a regular reset for my previous components */
    wire reset;
    assign reset = ~resetN;

    /*
     * INTAn connected to btn[2] through edge-to-pulse
     */
    /* using BTN2 so it's farther away from the reset button :-) */
    wire intackN;  
    wire intack_btn;
    reg intack = 1'b0;
    reg next_intack = 1'b0;
    assign intackN = ~intack;

    edge_to_pulse intackN_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[2]),
         .pulse_out(intack_btn));

    parameter ACK_STATE_NOT_ACTIVE = 3'b000;  
    parameter ACK_STATE_ACTIVE = 3'b001;

    reg [2:0] ack_curr_state = ACK_STATE_NOT_ACTIVE;
    reg [2:0] ack_next_state;

    parameter ACK_NOT_ACTIVE = 1'b0;
    parameter ACK_ACTIVE = 1'b1;

    always @(posedge(reset),posedge(MCLK))
    begin
        if( reset ) 
        begin
            ack_curr_state <= ACK_STATE_NOT_ACTIVE;
            intack <= ACK_NOT_ACTIVE;
        end
        else
        begin
            ack_curr_state <= ack_next_state;
            intack <= next_intack;
        end
    end

    /* State machine to control the intackN line. Each button press toggles the
     * line.   high -> press (low) -> press (high) -> press (low) -> etc.
     */
    always @(ack_curr_state,intack_btn)
    begin
        ack_next_state <= ack_curr_state;
        next_intack <= intack;

        case( ack_curr_state ) 
            ACK_STATE_NOT_ACTIVE :
            begin
                if( intack_btn==1'b1 ) 
                begin
                    ack_next_state <= ACK_STATE_ACTIVE;
                    next_intack <= ACK_ACTIVE;
                end
            end

            ACK_STATE_ACTIVE :
            begin
                if( intack_btn==1'b1 ) 
                begin
                    ack_next_state <= ACK_STATE_NOT_ACTIVE;
                    next_intack <= ACK_NOT_ACTIVE;
                end
            end

            default :
            begin
                ack_next_state <= ACK_STATE_NOT_ACTIVE;
                next_intack <= ACK_NOT_ACTIVE;
            end

        endcase
    end

    assign Led[1] = intackN;

    /*
     *  Incoming IRQ with switches. Use btn[1] to trigger irq after choosing
     *  what switches are set.
     */
    /* SW[7:0] are IRQ */
    wire [7:0] intreq;
    wire int_trigger_btn;
//    assign intreq = sw;
    assign intreq = sw & { 8{int_trigger_btn} };

    edge_to_pulse trigger_int_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[1]),
         .pulse_out(int_trigger_btn));

    /* interrupt pending line */
    wire int;
    assign Led[0] = int;
     
    /* Leds not (yet) used */
    assign Led[7:2] = 0;

    /* register interface */
    reg [1:0] register_select;
    reg register_readwrite = `RW_READ;
    reg [7:0] register_data;

    /* data interface -- inout so is absolutely crazy bonkers nightmare :-O */
    wire [7:0] data_wire;

    assign data_wire = register_readwrite==`RW_READ ? 8'hzz : register_data;

    /*
     *  PIC Programmable Interrupt Controller
     */
    wire [3:0] pic_debug_state;

    pic run_pic
        (.clk(MCLK),
         .resetN(resetN),
         .data(data_wire),
         .select(register_select),
         .readwrite(register_readwrite),
         .intreq(intreq),
         .intackN(intackN),

         // output(s)
         .int_out(int),
         
         .debug_state(pic_debug_state) 
         );

    /*
     *  The PIC Test ROM
     */

    wire rom_exe;

    edge_to_pulse rom_step_edge_to_pulse
        (.clk(MCLK),
         .reset(reset),
         .edge_in(btn[3]),
         .pulse_out(rom_exe));

    reg [10:0] rom_data;
    reg rom_en = 1'b0;

    reg [7:0] rom_address=8'h00;
    reg [7:0] next_rom_address;

    reg [2:0] rom_state;
    reg [2:0] next_rom_state;

    reg rom_rw_flag;
    reg next_rom_rw_flag;

    reg [1:0] rom_regnum;
    reg [1:0] next_rom_regnum;

    reg [7:0] rom_reg_data;
    reg [7:0] next_rom_reg_data;

    parameter ROM_STATE_IDLE = 3'b000;
    parameter ROM_STATE_EXECUTING = 3'b001;
    parameter ROM_STATE_WAIT = 3'b010;

    always @(posedge(reset),posedge(MCLK))
    begin
        if( reset ) 
        begin
            rom_state <= ROM_STATE_IDLE;
            rom_address <= 8'h00;

            rom_rw_flag <= `RW_READ;
            rom_regnum <= `SEL_OCR;
            rom_reg_data <= 8'hzz;
            rom_en <= 1'b0;
        end
        else
        begin
            rom_state <= next_rom_state;
            rom_address <= next_rom_address;

            rom_rw_flag <= next_rom_rw_flag;
            rom_regnum <= next_rom_regnum;
            rom_reg_data <= next_rom_reg_data;
            rom_en <= 1'b1;
        end
    end

    always @(*) 
    begin
        next_rom_address <= rom_address;
        next_rom_state <= rom_state;

        next_rom_rw_flag <= rom_rw_flag;
        next_rom_regnum <= rom_regnum;
        next_rom_reg_data <= rom_reg_data;

//        register_readwrite <= `RW_READ;
//        register_select <= `SEL_OCR;
//        register_data <= 8'hzz;
        register_readwrite <= rom_rw_flag;
        register_select <= rom_regnum;
        register_data <= rom_data;

        case( rom_state ) 
            ROM_STATE_IDLE :
            begin
                if( rom_exe==1'b1 )
                begin
                    next_rom_state <= ROM_STATE_EXECUTING;
                    
                    /* decode */
                    next_rom_rw_flag <= rom_data[10];
                    next_rom_regnum <= rom_data[9:8];
                    next_rom_reg_data <= rom_data[7:0];
                end
            end

            ROM_STATE_EXECUTING :
            begin
                /* execute */
                register_readwrite <= rom_rw_flag;
                register_select <= rom_regnum;
                register_data <= rom_data;
                next_rom_state <= ROM_STATE_WAIT;
            end

            ROM_STATE_WAIT : 
            begin
                next_rom_state <= ROM_STATE_IDLE;
                /* advance to next rom address */
                next_rom_address <= rom_address + 8'h01;
                register_readwrite <= `RW_READ;
//                register_select <= `SEL_ISR;
//                register_data <= 8'hzz;

                next_rom_rw_flag <= `RW_READ;
//                next_rom_regnum <= `SEL_OCR;
//                next_rom_reg_data <= 8'hzz;
            end

            default:
            begin
                next_rom_state <= ROM_STATE_IDLE;
            end
        endcase
    end

    always @(rom_address,rom_en)
    begin
        if( rom_en==1'b1 )
        begin
            case( rom_address )
                /* specify an automatic rotating through the OCR */
//                8'h00 : rom_data <= { `RW_READ, `SEL_OCR, 8'h00 };

//                /* specify priority 2 for irq 6 via the OCR */
//                8'h00 : rom_data <= { `RW_WRITE, `SEL_OCR, 8'h46 };

                /* specify priority 7 for irq 0 via the OCR */
                /* specify priority 0 for irq 7 via the OCR */
                8'h00 : rom_data <= { `RW_WRITE, `SEL_OCR, 8'he0 };
                8'h01 : rom_data <= { `RW_WRITE, `SEL_OCR, 8'h07 };

                /* enable (almost) all interrupts */
                8'h02 : rom_data <= { `RW_WRITE, `SEL_IMR, 8'he7 };

                /* enable interrupt IR5 (activate IR7-IR0 afterwards) */
    //            8'h01 : rom_data <= { `RW_WRITE, `SEL_IMR, 8'h20 };

                /* read the IMR back */
//                8'h02 : rom_data <= { `RW_READ, `SEL_IMR, 8'hzz };

                /* after the first INTAn pulse, read ISR followed by IRR */
                8'h03 : rom_data <= { `RW_READ, `SEL_ISR, 8'hzz };
                8'h04 : rom_data <= { `RW_READ, `SEL_IRR, 8'hzz };

                /* after the second INTAn pulse, interrupt vector should be
                 * displayed 
                 */

                /* repeat the above sequence with IR4 and IR6 -- read the two
                 * registers after each interrupt
                 */
                /* enable IR4, read ISR, IRR after */
//                8'h04 : rom_data <= { `RW_WRITE, `SEL_IMR, 8'h10 };
                8'h05 : rom_data <= { `RW_READ, `SEL_ISR, 8'hzz };
                8'h06 : rom_data <= { `RW_READ, `SEL_IRR, 8'hzz };

                /* enable IR6, read ISR, IRR after */
                8'h07 : rom_data <= { `RW_WRITE, `SEL_IMR, 8'h40 };
                8'h08 : rom_data <= { `RW_READ, `SEL_ISR, 8'hzz };
                8'h09 : rom_data <= { `RW_READ, `SEL_IRR, 8'hzz };

                /* remainder of the ROM should be harmless */
                default :
                    rom_data <= { `RW_READ, 9'b000000000 }; 
            endcase
        end
    end

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
          .word_in( { rom_address, data_wire } ),
          .display_mask_in(4'b1111),

          /* outputs */
          .seg(seg),
          .an(an),
          .dp(dp) );

    /*
     * Test/Debug Signals
     */
    assign PIO[73:72] = register_select;
//    assign PIO[72] = int;
//    assign PIO[73] = intackN;
    assign PIO[74] = register_readwrite;
    assign PIO[75] = rom_exe;

    assign PIO[83:76] = data_wire;

    assign PIO[87:84] = rom_address[3:0];
//    assign PIO[87:84] = pic_debug_state;


endmodule


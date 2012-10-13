/* Hopelessly Naive Carry Lookahead Adder.
 *
 * ECE 4/530 Fall 2012
 * David Poole 25-Sep-2012
 *
 * Based on secion 5.4 of
 * _Fundamentals of Digital Logic with Verilog Design_, 2e.
 *      Brown, Vranesic
 *
 * @book{brown2009fundamentals,
 *   title={Fundamentals of Digital Logic with VHDL Design},
 *   author={Brown, S.D. and Vranesic, Z.G.},
 *   isbn={9780073529530},
 *   lccn={2008001634},
 *   series={McGraw-Hill Series in Electrical and Computer Engineering},
 *   url={http://books.google.com/books?id=qrMgPwAACAAJ},
 *   year={2009},
 *   publisher={McGraw-Hill}
 * }
 *
 * The math on this is quite interesting!
 *
 */

`timescale 1 ns / 10 ps

module CarryLookaheadAdder
    ( input wire [7:0] X,
      input wire [7:0] Y,
      input wire C0,
      
      output wire [7:0] sum,
      output wire carry_out
    );

    wire C1, C2, C3, C4, C5, C6, C7, C8;

    assign sum[0] = X[0] ^ Y[0] ^ C0;

    assign C1 = (X[0] & Y[0]) | ((X[0] | Y[0]) & C0);
    assign sum[1] = X[1] ^ Y[1] ^ C1;

    assign C2 = (X[1] & Y[1]) | ((X[1] | Y[1]) & C1);
    assign sum[2] = X[2] ^ Y[2] ^ C2;

    assign C3 = (X[2] & Y[2]) | ((X[2] | Y[2]) & C2);
    assign sum[3] = X[3] ^ Y[3] ^ C3;

    assign C4 = (X[3] & Y[3]) | ((X[3] | Y[3]) & C3);
    assign sum[4] = X[4] ^ Y[4] ^ C4;

    assign C5 = (X[4] & Y[4]) | ((X[4] | Y[4]) & C4);
    assign sum[5] = X[5] ^ Y[5] ^ C5;

    assign C6 = (X[5] & Y[5]) | ((X[5] | Y[5]) & C5);
    assign sum[6] = X[6] ^ Y[6] ^ C6;

    assign C7 = (X[6] & Y[6]) | ((X[6] | Y[6]) & C6);
    assign sum[7] = X[7] ^ Y[7] ^ C7;

    assign C8 = (X[7] & Y[7]) | ((X[7] | Y[7]) & C7);
    assign carry_out = C8;

    /* TODO 16-bit? */
    
    initial
    begin
        $display("hello");
    end

endmodule


// Register
// _FPGA Prototyping by Verilog Examples_ Cho 2008
//
// ECE4/530 Fall 2012
//
// David Poole 22-Sep-2012

module Register
    #( parameter WIDTH=16 )
    ( input wire clk,
      input wire load,
      input wire reset,
      input wire [WIDTH-1:0] d,
      output reg [WIDTH-1:0] q );

    always @(posedge clk, posedge reset )
    begin
        if( reset ) 
        begin
            q <= 0;
        end
        else if( load )
        begin
            q <= d;
        end
    end

endmodule



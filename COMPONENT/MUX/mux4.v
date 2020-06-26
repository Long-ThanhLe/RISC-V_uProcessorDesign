`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2020 11:11:21 PM
// Design Name: 
// Module Name: mux4
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mux4(
    in0,
    in1,
    in2,
    in3,
    sel,
    out
    );
input [31:0] in0, in1, in2, in3;
input [1:0] sel;
output [31:0] out;

reg [31:0] out;

initial begin
    out <= 32'd0;
end

always @(*)
begin

case (sel)
    2'd0: out <= in0;
    2'd1: out <= in1;
    2'd2: out <= in2;
    2'd3: out <= in3;
endcase
end

endmodule

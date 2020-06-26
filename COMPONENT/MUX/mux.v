`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2020 11:08:09 PM
// Design Name: 
// Module Name: mux
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


module mux(
    in0,
    in1,
    sel,
    out
    );
input [31:0] in1, in0;
output [31:0] out;
input sel;

reg [31:0] out;

initial begin
    out <= 32'd0;
end

always @(*)
begin
    case (sel)
    0: out <= in0;
    1: out <= in1;
    endcase
end

endmodule

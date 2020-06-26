`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/14/2020 04:36:35 PM
// Design Name: 
// Module Name: ALU
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


module ALU(
    in1,
    in2,
    out,
    sel
    );

input [3:0] sel;
output [31:0] in1, in2, out;

reg [31:0] out;
parameter ADD = 0;
parameter SUB = 1;
parameter XOR = 2;
parameter OR  = 3;
parameter AND = 4;
parameter SLL = 5;
parameter SRL = 6;
parameter SRA = 7;
parameter USLT= 8;
parameter SLT = 9;

initial begin
    out <= 32'd0;
end

always @(*) 
begin
    case (sel)
    ADD:
        out <= in1 + in2;
    SUB:
        out <= in1 - in2;
    XOR:
        out <= in1 ^ in2;
    OR:
        out <= in1 | in2;
    AND:
        out <= in1 & in2;
    SLL:
        out <= in1 << in2;
    SRL:
        out <= in1 >> in2;
    SRA:
        out <= in1 >>> in2;
    USLT:
        out <= ( in1 < in2) ? 32'd1 : 32'd0;
    SLT:
        out <= ( $signed(in1) < $signed(in2)) ? 32'd1 : 32'd0;
    
    endcase
end

endmodule

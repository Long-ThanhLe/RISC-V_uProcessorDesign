`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/30/2020 10:33:36 AM
// Design Name: 
// Module Name: pipeline_reg
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


module pipeline_reg(
    clk,
    in,
    out
    );
input clk;
input [31:0] in;
output reg [31:0] out;

always @(posedge clk)
begin
    out <= in;
end

initial begin
    out = 32'd0;
end
endmodule

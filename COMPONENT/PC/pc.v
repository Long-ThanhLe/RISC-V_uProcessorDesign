`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 04:33:15 PM
// Design Name: 
// Module Name: pc
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


module pc(
    in,
    out,
    clk
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

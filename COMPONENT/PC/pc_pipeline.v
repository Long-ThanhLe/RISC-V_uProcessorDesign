`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2020 04:57:22 PM
// Design Name: 
// Module Name: pc_pipeline
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


module pc_pipeline(
    in,
    out,
    stall,
    clk
    );
    
input clk, stall;
input [31:0] in;
output reg [31:0] out;

always @(posedge clk)
begin
    if (stall == 1'b0)
        out <= in;
end

initial begin
out = 32'd0;
end

endmodule

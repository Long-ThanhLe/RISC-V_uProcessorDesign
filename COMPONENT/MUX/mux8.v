`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2020 03:47:45 PM
// Design Name: 
// Module Name: mux8
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


module mux8(
    in0,
    in1,
    in2,
    in3,
    in4,
    in5,
    in6,
    in7,
    sel,
    out
    );
input [31:0] in0, in1, in2, in3, in4, in5, in6, in7;
input [2:0] sel;
output reg [31:0] out;

initial begin 
    out <= 32'd0;
end

always @(*)
begin
    case (sel)
    3'd0: out = in0;
    3'd1: out = in1;
    3'd2: out = in2;
    3'd3: out = in3;
    3'd4: out = in4;
    3'd5: out = in5;
    3'd6: out = in6;
    3'd7: out = in7;
    endcase

end

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/24/2020 11:14:27 PM
// Design Name: 
// Module Name: branch_comp
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


module branch_comp(
    inA,
    inB,
    BrUn,
    BrEq,
    BrLT
    );
input [31:0] inA, inB;
input BrUn;
output BrEq, BrLT;
reg BrEq, BrLT;

initial begin
    BrEq <= 1'b0;
    BrLT <= 1'b0;
end

always @(*)
begin

case (BrUn)
    1'b0:
        begin
            BrEq <= (inA == inB) ? 1'b1 : 1'b0;
            BrLT <= ($signed(inA) < $signed(inB)) ? 1'b1 : 1'b0;
        end
    1'b1:
        begin
            BrEq <= (inA == inB) ? 1'b1 : 1'b0;
            BrLT <= (inA <  inB) ? 1'b1 : 1'b0;
        end
endcase

end

endmodule

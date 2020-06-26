`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 08:44:20 AM
// Design Name: 
// Module Name: imm_gen
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


module imm_gen(
    ImmSel,
    inst,
    imm
    );
    
input [31:0] inst;
input [2:0] ImmSel;
output [31:0] imm;

reg [31:0] imm;

parameter R_TYPE = 3'd5;
parameter B_TYPE = 3'd2;
parameter I_TYPE = 3'd0;
parameter S_TYPE = 3'd1;
parameter U_TYPE = 3'd3;
parameter J_TYPE = 3'd4;

initial begin
    imm <= 32'd0;
end

always @(*)
begin
case (ImmSel)
    R_TYPE: imm[31:0] = {31'd0}; 
    B_TYPE: imm[31:0] = {{20{inst[31]}}, {inst[7]}, {inst[30:25]}, {inst[11:8]}, {1'b0}};
    I_TYPE: imm[31:0] = {{20{inst[31]}}, {inst[31:20]}};
    S_TYPE: imm[31:0] = {{20{inst[31]}}, {inst[31:25]}, {inst[11:7]}};
    U_TYPE: imm[31:0] = {inst[31:12], {12'd0}};
    J_TYPE: imm[31:0] = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], {1'b0}};
endcase


end

endmodule

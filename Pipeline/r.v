`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2020 03:37:47 PM
// Design Name: 
// Module Name: r
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


module r(
    inst,
    re1,
    re2,
    rs1,
    rs2
    );
input [31:0] inst;
output reg [4:0] rs1, rs2;
output reg re1, re2;

parameter R_TYPE = 5'b01100;
parameter B_TYPE = 5'b11000;
parameter I_CAL = 5'b00100;
parameter I_LOAD = 5'b00000;
parameter S_TYPE = 5'b01000;
parameter LUI_TYPE = 5'b01101;
parameter AUIPC_TYPE = 5'b00101;
parameter JAL_TYPE = 5'b11011;
parameter JALR_TYPE = 5'b11001;

initial begin
    rs1 = 0;
    rs2 = 0;
    re1 = 0;
    re2 = 0;
end

always @(*)
begin
    case (inst[6:2])
    R_TYPE: re1 = 1'b1; 
    I_CAL:  re1 = 1'b1;
    I_LOAD: re1 = 1'b1;
    S_TYPE: re1 = 1'b1;
    B_TYPE: re1 = 1'b1;
    LUI_TYPE: re1 = 1'b0;
    AUIPC_TYPE: re1 = 1'b0;
    JAL_TYPE: re1 = 1'b0;
    JALR_TYPE: re1 = 1'b1;
    endcase
end

always @(*)
begin
    case (inst[6:2])
    R_TYPE: re2 = 1'b1; 
    I_CAL:  re2 = 1'b0;
    I_LOAD: re2 = 1'b0;
    S_TYPE: re2 = 1'b0;
    B_TYPE: re2 = 1'b1;
    LUI_TYPE: re2 = 1'b0;
    AUIPC_TYPE: re2 = 1'b0;
    JAL_TYPE: re2 = 1'b0;
    JALR_TYPE: re2 = 1'b0;
    endcase
end

always @(*)
begin
    rs1 = inst[19:15];
    rs2 = inst[24:20];
end

endmodule

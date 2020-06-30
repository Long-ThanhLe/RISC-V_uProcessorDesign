`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2020 03:20:52 PM
// Design Name: 
// Module Name: we
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


module stadll(
    inst,
    we
    );

input [31:0] inst;
output reg we;

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
    we = 1'b0;
end

always @(*)
begin
    case (inst[6:2])
    R_TYPE: we = 1'b1; 
    I_CAL:  we = 1'b1;
    I_LOAD: we = 1'b1;
    S_TYPE: we = 1'b0;
    B_TYPE: we = 1'b0;
    LUI_TYPE: we = 1'b1;
    AUIPC_TYPE: we = 1'b1;
    JAL_TYPE: we = 1'b1;
    JALR_TYPE: we = 1'b1;
    endcase
end

endmodule

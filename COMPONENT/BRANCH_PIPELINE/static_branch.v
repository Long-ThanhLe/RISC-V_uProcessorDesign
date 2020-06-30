`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2020 12:14:16 PM
// Design Name: 
// Module Name: static_branch
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


module static_branch(
    instD,
    instE,
    pcmux_sel_X,
    pcmux_sel_F,
    predict_fail,
    pcmux_sel_out
    );
input [31:0] instE, instD;
input pcmux_sel_X, pcmux_sel_F;
output reg [3:0] pcmux_sel_out;
output reg predict_fail;
reg pcmux_sel_D_out;

parameter B_TYPE = 5'b11000;

always @(*) 
begin
    case (instE[6:2])
    B_TYPE: begin
        if (pcmux_sel_X == 1'b1) // Wrong predict
        begin
            predict_fail = 1'b1;
            pcmux_sel_out = 3'd5; // Branch
        end
        else // as predict
        begin
            predict_fail = 1'b0;
            pcmux_sel_out = {{2'd0},pcmux_sel_F};
        end
    end
    default: begin
        predict_fail = 1'b0;
        pcmux_sel_out = {{2'd0},pcmux_sel_F};
    end
    endcase
end

endmodule

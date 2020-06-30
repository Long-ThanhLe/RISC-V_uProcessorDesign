`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2020 09:46:24 PM
// Design Name: 
// Module Name: control_pipeline
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


module control_pipeline(
    clk,
    instF,
    instD,
    instX,
    instM,
    instW,
    BrEq,
    BrLT,
    PCSel,
    ImmSel,
    RegWen,
    BrUn,
    BSel,
    ASel,
    ALUSel,
    MemRW,
    WBSel,
    RSel,
    WSel
    );

input clk, BrEq, BrLT;
input [31:0]  instF, instD,  instX, instM, instW;


output reg [3:0] ALUSel;
output reg [2:0] PCSel, ImmSel, RSel, WBSel, ASel, BSel;
output reg [1:0] WSel;
output reg BrUn, RegWen, MemRW;


wire [31:0] pc_sel_F;

/*
    Keep Zone
*/

wire [31:0] pc_in, pc_in_stall, pc_in_branch_predict, pc_in_branch_correct , pc_out_branch_predict, pc_out_branch_correct, jal_pc, jal_imm;
wire [31:0] pc_out, pc_plus4_out, pc_plus4_out_M;
wire [4:0] rs1, rs2, rd;
wire [31:0] rs1_out, rs2_out, imm_out, alumux1_out, alumux2_out, aluout, dmem_out, wb_out;
wire [31:0] instF, alutargetout;
wire br_eq, br_lt, regfilemux_sel, cmpop, alumux1_sel, alumux2_sel, dmem_sel;
wire [2:0] imm_sel, pcmux_sel, RSel_ctl;
wire [3:0] aluop;
wire [1:0] wbmux_sel, ASrc, BSrc, WSel_ctl;

parameter IMM_J_TYPE = 3'd4;
parameter ADD = 0;


/*
    Pipeline
*/
reg stallD, stallX, stallM, stallW, stall_wait;
reg killF, killD, killX, killM, killW, kill_wait;
wire killF_next, killD_next, killX_next, killM_next, killW_next, kill_en_next;

wire stall, pc_true, branch_en, branch_correct, predict_fail;

assign rs1 = instD[19:15];
assign rs2 = instD[24:20];
assign rd = instW[11:7];

/*    Pipeline Control   */

kill      kill(.instF(instF), .instD(instD), .instX(instX), .instM(instM), .instW(instW), .predict_fail(predict_fail),
                .in_killF(killF), .in_killD(killD), .in_killX(killD), .in_killM(killM), .in_killW(killW),
                .killF_next(killF_next), .killD_next(killD_next), .killX_next(killX_next), .killM_next(killM_next), .killW_next(killW_next), .kill_en_next(kill_en_next)
            );
stall_bypass stall_bypass(/*.instF(instF), */.instD(instD), .instE(instX),/* .instM(instM), */.instW(instW), .alumux1(alumux1_sel), .alumux2(alumux2_sel),
                .ASrc(ASrc), .BSrc(BSrc), .stall(stall)
            );
static_branch branch_predict(
    .instD(instD),
    .instE(instX),
    .pcmux_sel_X(pc_true),
    .pcmux_sel_F(pc_sel_F),
    .predict_fail(predict_fail),
    .pcmux_sel_out(pcmux_sel)
    );

control   ControlF(.inst(instF), .PCSel(pc_sel_F));
control   ControlD(.inst(instD));
control   ControlX(.inst(instX), .BrEq(br_eq), .BrLT(br_lt), .PCSel(pc_true), .ImmSel(imm_sel), .BrUn(cmpop), .BSel(alumux2_sel), .ASel(alumux1_sel), .ALUSel(aluop));
control   ControlM(.inst(instM), .MemRW(dmem_sel), .WBSel(wbmux_sel), .RSel(RSel_ctl), .WSel(WSel_ctl));
control   ControlW(.inst(instW), .RegWen(regfilemux_sel));

// pipeline reg
always @(posedge clk)
begin

    stall_wait <= stall;
    stallD <= stall_wait; 
    stallX <= stallD;
    stallM <= stallX;
    stallW <= stallM;

    // kill
    if (kill_en_next) begin
        killF <= killF_next;
        killD <= killD_next;
        killX <= killX_next;
        killM <= killM_next;
        killW <= killW_next;
    end else begin
        killF <= 1'b0;
        killD <= killF;
        killX <= killD;
        killM <= killX;
        killW <= killM;
    end
end

/*
    Initial 
*/
initial begin
    
    // // stall signal
    // stallD <= 0; 
    // stallX <= 0;
    // stallM <= 0;
    // stallW <= 0;
    // stall_wait <= 0;

    // // kill signal
    // killF <= 0;
    // killD <= 0;
    // killX <= 0;
    // killM <= 0;
    // killW <= 0;
    // kill_wait <= 0;
    // 
end

endmodule

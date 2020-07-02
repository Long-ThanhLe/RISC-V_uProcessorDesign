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
    WSel,
    stall_sig
    );

input clk, BrEq, BrLT, stall_sig;
input [31:0]  instF, instD,  instX, instM, instW;


output [3:0] ALUSel;
output [2:0] BSel;
output [2:0] ASel, ImmSel, RSel, PCSel;
output [1:0] WSel, WBSel;
output BrUn, RegWen, MemRW;


wire pc_sel_F;

/*
    Keep Zone
*/

// wire [31:0] pc_in, pc_in_stall, pc_in_branch_predict, pc_in_branch_correct , pc_out_branch_predict, pc_out_branch_correct, jal_pc, jal_imm;
// wire [31:0] pc_out, pc_plus4_out, pc_plus4_out_M;
wire [4:0] rs1, rs2, rd;
// wire [31:0] rs1_out, rs2_out, imm_out, alumux1_out, alumux2_out, aluout, dmem_out, wb_out;
wire [31:0] instF;
wire alumux1_sel, alumux2_sel;
// wire [2:0] imm_sel;
// wire [3:0] aluop;
// wire [1:0] wbmux_sel;

parameter IMM_J_TYPE = 3'd4;
parameter ADD = 0;


/*
    Pipeline
*/
reg stallD, stallX, stallM, stallW, stall_wait;
reg killF, killD, killX, killM, killW, kill_wait;
wire killF_next, killD_next, killX_next, killM_next, killW_next, kill_en_next;

wire stall, pc_true, predict_fail;
wire MemRW_ctl , RegWen_ctl;
wire [1:0] WBSel_ctl, WSel_ctl;
wire [2:0] RSel_ctl;


assign rs1 = instD[19:15];
assign rs2 = instD[24:20];
assign rd = instW[11:7];

/*    Pipeline Control   */

kill      kill(.instF(instF), .instD(instD), .instX(instX), .instM(instM), .instW(instW), .predict_fail(predict_fail),
                .in_killF(killF), .in_killD(killD), .in_killX(killD), .in_killM(killM), .in_killW(killW),
                .killF_next(killF_next), .killD_next(killD_next), .killX_next(killX_next), .killM_next(killM_next), .killW_next(killW_next), 
                .kill_en_next(kill_en_next));
stall_bypass stall_bypass(.instF(instF), .instD(instD), .instE(instX), .instM(instM), .instW(instW), .alumux1(alumux1_sel), .alumux2(alumux2_sel),
                .ASrc(ASel), .BSrc(BSel), .stall(stall));
static_branch branch_predict(.instF(instF), .instD(instD), .instE(instX), .pcmux_sel_X(pc_true), .pcmux_sel_F(pc_sel_F), .predict_fail(predict_fail), .pcmux_sel_out(PCSel),
                                .killD(killD), .killF(killF), .killE(killX), .stall_in(stall), .stall_out(stall_sig));

control   ControlF(.inst(instF), .PCSel(pc_sel_F), .ImmSel(ImmSel));
control   ControlD(.inst(instD));
control   ControlX(.inst(instX), .BrEq(BrEq), .BrLT(BrLT), .PCSel(pc_true), .BrUn(BrUn), .BSel(alumux2_sel), .ASel(alumux1_sel), .ALUSel(ALUSel));

control   ControlM(.inst(instM), .MemRW(MemRW_ctl), .WBSel(WBSel_ctl), .RSel(RSel_ctl), .WSel(WSel_ctl));
control   ControlW(.inst(instW), .RegWen(RegWen_ctl));

// kill
assign MemRW = MemRW_ctl & ~killM & ~stallM;
assign RegWen = RegWen_ctl & ~killW & ~stallW;
assign WBSel = WBSel_ctl & {2{~killM}} & {2{~stallM}};
assign WSel = WSel_ctl & {2{~killM}} & {2{~stallM}};
assign RSel = RSel_ctl & {3{~killM}} & {3{~stallM}};

// pipeline reg
always @(posedge clk)
begin

    // stall_wait <= stall; 
    // stallD <= stall_wait; 
    // stallX <= stallD;
    // stallM <= stallX;
    // stallW <= stallM;
    stallD <= 1'b0; 
    stallX <= stall;
    stallM <= stallX;
    stallW <= stallM;

    // kill
    if (kill_en_next) begin
        killF <= killF_next;
        killD <= killD_next;
        killX <= killX_next;
        killM <= killM_next | killX;
        killW <= killW_next | killM;
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
    
    // stall signal
    stallD <= 0; 
    stallX <= 0;
    stallM <= 0;
    stallW <= 0;
    stall_wait <= 0;

    // kill signal
    killF <= 0;
    killD <= 0;
    killX <= 0;
    killM <= 0;
    killW <= 0;
    kill_wait <= 0;
    
end

endmodule

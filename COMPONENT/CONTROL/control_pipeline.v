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
    // instruction for each stage
    instF,
    instD,
    instX,
    instM,
    instW,
    // F stage control sig
    ImmSel,
    PCSel,
    // D stage control sig
        // compare
    BrEq,
    BrLT,
    BrUn,
        // bypass source
    ASrc_bypass,
    BSrc_bypass,
        // A, B source
    ASrc,
    BSrc,
    // X stage control sig
    ALUSel,
    // M stage control sig
    MemRW,
    RSel,
    WSel,
    WBSel,
    // WB stage control sig
    RegWen,
    // stall signal for F, D stage
    stall_sig
    );

input [31:0]  instF, instD,  instX, instM, instW;
input clk, BrEq, BrLT;
// F
output [2:0] ImmSel;
output PCSel;
// D
output BrUn, ASrc, BSrc;
output [1:0] ASrc_bypass, BSrc_bypass;
// X
output [3:0] ALUSel;
// M
output [1:0] WSel;
output RegWen, MemRW;
// W
output [1:0] WBSel;
output stall_sig;



// Internal signals

wire [4:0] rs1, rs2, rd;
assign rs1 = instD[19:15];
assign rs2 = instD[24:20];
assign rd = instW[11:7];


parameter IMM_J_TYPE = 3'd4;
parameter ADD = 0;


/*
    Pipeline signals
*/

reg stallD, stallX, stallM, stallW, stall_wait;
reg killF, killD, killX, killM, killW, kill_wait;
wire killF_next, killD_next, killX_next, killM_next, killW_next, kill_en_next;


// wire stall, pc_true, predict_fail;
// wire MemRW_ctl , RegWen_ctl;
// wire [1:0] WBSel_ctl, WSel_ctl;
// wire [2:0] RSel_ctl;
wire PCSelF, PCSelX;
wire need_correct;


/*    Pipeline Control   */

kill      kill(.instF(instF), .instD(instD), .instX(instX), .instM(instM), .instW(instW), .need_correct(need_correct),
                .in_killF(killF), .in_killD(killD), .in_killX(killD), .in_killM(killM), .in_killW(killW),
                .killF_next(killF_next), .killD_next(killD_next), .killX_next(killX_next), .killM_next(killM_next), .killW_next(killW_next), 
                .kill_en_next(kill_en_next));

stall_bypass stall_bypass(  .instF(instF), .instD(instD), .instE(instX), .instM(instM), .instW(instW), 
                            .alumux1(ASrc), .alumux2(BSrc), 
                            .ASrc(ASel), .BSrc(BSel), 
                            .stall(stall));

static_branch branch_predict(.instF(instF), .instD(instD), .instE(instX), 
                            .PCSelX(PCSelX), 
                            .PCSelF(PCSelF), 
                            .need_correct(need_correct), 
                            .PCSelF_out(PCSel),
                            .killD(killD), .killF(killF), .killX(killX), 
                            .stall(stall)
                            );

control   ControlF(.inst(instF), .PCSel(PCSelF), .ImmSel(ImmSel));
control   ControlD(.inst(instD), .BrEq(BrEq), .BrLT(BrLT), .PCSel(pc_true), .BrUn(BrUn), .BSel(BSrc), .ASel(ASrc));
control   ControlX(.inst(instX), .ALUSel(ALUSel));
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

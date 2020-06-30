`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/28/2020 12:19:16 AM
// Design Name: 
// Module Name: pipeline
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


module pipeline();    

reg clk;
reg [31:0] count;
wire [31:0] pc_in, pc_in_stall, pc_in_branch_predict, pc_in_branch_correct , pc_out_branch_predict, pc_out_branch_correct, jal_pc, jal_imm, pc_sel_F;
wire [31:0] pc_out, pc_plus4_out, pc_plus4_out_M;
wire [4:0] rs1, rs2, rd;
wire [31:0] rs1_out, rs2_out, imm_out, alumux1_out, alumux2_out, aluout, dmem_out, wb_out;
wire [31:0] instF, alutargetout;
wire br_eq, br_lt, regfilemux_sel, cmpop, alumux1_sel, alumux2_sel, dmem_sel;
wire [2:0] imm_sel, RSel, pcmux_sel;
wire [3:0] aluop;
wire [1:0] wbmux_sel, WSel, ASrc, BSrc;

parameter IMM_J_TYPE = 3'd4;
parameter ADD = 0;


/*
    Pipeline
*/
wire [31:0] pcD, instD, pcX, rs1X, rs2X, instX, pcM, aluM, rs2M, instM, instW, dataW;
reg stallD, stallX, stallM, stallW, stall_wait;
reg killF, killD, killX, killM, killW, kill_wait;
wire killF_next, killD_next, killX_next, killM_next, killW_next, kill_en_next;

wire stall, pc_true, branch_en, branch_correct, predict_fail;

assign rs1 = instD[19:15];
assign rs2 = instD[24:20];
assign rd = instW[11:7];

/*    F       */ 
// Target
// 0: PC + 4
// 1: ALU from X
// 2: Stall (pc_out)
// 3: JAL
// 4: JALR
// 5: Branch take
// 6: Branch not take
mux8      PCmux(.in0(pc_plus4_out), .in1(aluout), .in2(pc_out), .in3(alutargetout),
                .in4(32'd0), .in5(aluout), .in6(32'd0), .in7(32'd0),
                .sel(pcmux_sel), .out(pc_in));

// IMGEN for JAL
// ALU calculation for target
imm_gen   IMM_JAL( .ImmSel(IMM_J_TYPE), .inst(instD), .imm(jal_imm));
ALU       ALU_target(.in1(jal_imm), .in2(pc_out), .out(alutargetout), .sel(ADD));

pc        PC   (.clk(clk), .in(pc_in), .out(pc_out));
add_4     PC_4 (.in(pc_out), .out(pc_plus4_out));
IMEM      IMEM (.PC(pc_out), .inst(instF));

pipeline_reg pcD_reg  (.in(pc_out), .out(pcD), .clk(clk));
pipeline_reg instD_reg(.in(instF), .out(instD), .clk(clk));
/*    D    W    */
regs      REG_FILES (.data_D(dataW), .addr_D(rd), .addr_A(rs1), 
                    .addr_B(rs2), .Wen(regfilemux_sel ), .clk(clk), .data_A(rs1_out), .data_B(rs2_out));

pipeline_reg pcX_reg (.in(pcD), .out(pcX), .clk(clk));
pipeline_reg rs1X_reg(.in(rs1_out), .out(rs1X), .clk(clk));
pipeline_reg rs2X_reg(.in(rs2_out), .out(rs2X), .clk(clk));
pipeline_reg instX_reg(.in(instD), .out(instX), .clk(clk));

/*    X        */
imm_gen   IMM_G( .ImmSel(imm_sel), .inst(instX), .imm(imm_out));
branch_comp branch_comp(.inA(rs1X), .inB(rs2X), .BrEq(br_eq), .BrLT(br_lt), .BrUn(cmpop));
mux4       ALUmux1(.in0(rs1X), .in1(pcX), .in2(aluout), .in3(32'd0), .sel(ASrc), .out(alumux1_out));
mux4       ALUmux2(.in0(rs2X), .in1(imm_out), .in2(aluout), .in3(32'd0), .sel(BSrc), .out(alumux2_out));
ALU       ALU(.in1(alumux1_out), .in2(alumux2_out), .out(aluout), .sel(aluop));

pipeline_reg pcM_reg(.in(pcX), .out(pcM), .clk(clk));
pipeline_reg aluM_reg(.in(aluout), .out(aluM), .clk(clk));
pipeline_reg rs2M_reg(.in(rs2X), .out(rs2M), .clk(clk));
pipeline_reg instM_reg(.in(instX), .out(instM), .clk(clk));
/*    M       */
add_4     PC_M (.in(pcM), .out(pc_plus4_out_M));
dmem      DMEM(.addr(aluM), .dataw(rs2M), .datar(dmem_out), .clk(clk), .Wen(dmem_sel), .RSel(RSel), .WSel(WSel));
mux4      Wbmux(.in0(dmem_out), .in1(aluM), .in2(pc_plus4_out_M), .in3(32'd0), .out(wb_out), .sel(wbmux_sel));

pipeline_reg instW_reg(.in(instM), .out(instW), .clk(clk));
pipeline_reg dataW_reg(.in(wb_out), .out(dataW), .clk(clk));

/*    Pipeline Control   */

control_pipeline control_pipeline(
    .clk(clk),
    .instF(instF),
    .instD(instD),
    .instX(instX),
    .instM(instM),
    .instW(instW),
    .BrEq(br_eq),
    .BrLT(br_lt),
    .PCSel(pcmux_sel),
    .ImmSel(imm_sel),
    .RegWen(regfilemux_sel),
    .BrUn(cmpop),
    .BSel(BSrc),
    .ASel(ASrc),
    .ALUSel(aluop),
    .MemRW(dmem_sel),
    .WBSel(WSel),
    .RSel(RSel),
    .WSel(WSel)
    );

always
begin
    clk = 0;
    #100;
    clk = 1;
    count = count + 1;
    #100;
end

endmodule

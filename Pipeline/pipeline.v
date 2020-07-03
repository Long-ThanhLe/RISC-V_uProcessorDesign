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
wire [31:0] pc_in ;
wire [31:0] pc_out, pc_plus4_out, pc_plus4_out_M;
wire [4:0] rs1, rs2, rd;
wire [31:0] rs1_out, rs2_out, imm_out, alumux1_out, alumux2_out, aluout, dmem_out, wb_out;
wire [31:0] instF, alutargetout;
wire br_eq, br_lt, regfilemux_sel, cmpop, dmem_sel, stall_sig, ASrc, BSrc;
wire [2:0] imm_sel, RSel, pcmux_sel;
wire [3:0] aluop;
wire [1:0] wbmux_sel, WSel, ASrc_bypass, BSrc_bypass;

parameter IMM_J_TYPE = 3'd4;
parameter ADD = 4'd0;


/*
    Pipeline
*/
wire [31:0] pcD, instD, pcX, rs1X, rs2X, instX, pcM, aluM, rs2M, instM, instW, dataW;
wire [31:0] A_out, B_out, MDX, MDM;
wire [31:0] imm_D, imm_F, imm_X, imm_M, imm_W, pc_out_before_stall;

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

                        // ALU calculation for target
ALU       ALU_target(.in1(imm_F), .in2(pc_out), .out(alutargetout), .sel(ADD));

                        /*
                            Stall PC:
                            0: Not stall
                            1: Stall
                        */
pc_pipeline        PC   (.clk(clk), .in(pc_in), .out(pc_out), .stall(stall_sig));


add_4     PC_4 (.in(pc_out), .out(pc_plus4_out));
IMEM      IMEM (.PC(pc_out), .inst(instF));
imm_gen   IMM_GEN_F( .ImmSel(imm_sel), .inst(instF), .imm(imm_F));

pipeline_reg pcD_reg  (.in(pc_out), .out(pcD), .clk(clk), .stall(stall_sig));
pipeline_reg instD_reg(.in(instF), .out(instD), .clk(clk), .stall(stall_sig));
pipeline_reg imm_D_reg(.in(imm_F), .out(imm_D), .clk(clk), .stall(stall_sig));
/*    D        */
regs      REG_FILES (.data_D(dataW), .addr_D(rd), .addr_A(rs1), 
                    .addr_B(rs2), .Wen(regfilemux_sel ), .clk(clk), .data_A(rs1_out), .data_B(rs2_out));

/*
    ASrc[2:1]
    0: no bypass
    1: bypass E -> D
    2: bypass M -> D
    3: bypass W -> D
*/
mux4      ALUmux1_bypass(.in0(rs1_out), .in1(aluout), .in2(wb_out), .in3(dataW), .sel(ASrc_bypass), .out(ASrc_bypass_out));
mux       ALUmux1(.in0(A_out), .in1(pcD), .sel(ASrc), .out(alumux1_out));
mux4      ALUmux2(.in0(rs2_out), .in1(aluout), .in2(wb_out), .in3(dataW), .sel(BSrc_bypass), .out(BSrc_bypass_out));
mux       ALUmux2_bypass(.in0(B_out), .in1(imm_D), .sel(BSrc), .out(alumux2_out));

branch_comp branch_comp(.inA(alumux1_out), .inB(alumux2_out), .BrEq(br_eq), .BrLT(br_lt), .BrUn(cmpop));
//mux4       ALUmux1(.in0(rs1X), .in1(pcX), .in2(aluM), .in3(32'd0), .sel(ASrc), .out(alumux1_out));

pipeline_reg pcX_reg (.in(pcD), .out(pcX), .clk(clk), .stall(stall_sig));
pipeline_reg rs1X_reg(.in(alumux1_out), .out(rs1X), .clk(clk), .stall(stall_sig));
pipeline_reg rs2X_reg(.in(alumux2_out), .out(rs2X), .clk(clk), .stall(stall_sig));
pipeline_reg instX_reg(.in(instD), .out(instX), .clk(clk), .stall(stall_sig));
pipeline_reg imm_X_reg(.in(imm_D), .out(imm_X), .clk(clk), .stall(stall_sig));
pipeline_reg MDX_reg(.in(B_out), .out(MDX), .clk(clk), .stall(1'b0));


/*    X        */
ALU       ALU(.in1(alumux1_out), .in2(alumux2_out), .out(aluout), .sel(aluop));

pipeline_reg pcM_reg(.in(pcX), .out(pcM), .clk(clk), .stall(1'b0));
pipeline_reg aluM_reg(.in(aluout), .out(aluM), .clk(clk), .stall(1'b0));
pipeline_reg MDM_reg(.in(MDX), .out(MDM), .clk(clk), .stall(1'b0));
pipeline_reg instM_reg(.in(instX), .out(instM), .clk(clk), .stall(1'b0));
pipeline_reg imm_M_reg(.in(imm_X), .out(imm_M), .clk(clk), .stall(1'b0));

/*    M       */
add_4     PC_M (.in(pcM), .out(pc_plus4_out_M));
dmem      DMEM(.addr(aluM), .dataw(MDM), .datar(dmem_out), .clk(clk), .Wen(dmem_sel), .RSel(RSel), .WSel(WSel));
mux4      Wbmux(.in0(dmem_out), .in1(aluM), .in2(pc_plus4_out_M), .in3(32'd0), .out(wb_out), .sel(wbmux_sel));


/*    W       */
pipeline_reg instW_reg(.in(instM), .out(instW), .clk(clk), .stall(1'b0));
pipeline_reg dataW_reg(.in(wb_out), .out(dataW), .clk(clk), .stall(1'b0));
pipeline_reg imm_W_reg(.in(imm_M), .out(imm_W), .clk(clk), .stall(1'b0));


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
    .ASrc_bypass(ASrc_bypass),
    .BSrc_bypass(BSrc_bypass),
    .ALUSel(aluop),
    .MemRW(dmem_sel),
    .WBSel(wbmux_sel),
    .RSel(RSel),
    .WSel(WSel),
    .stall_sig(stall_sig)
    );

always
begin
    clk = 0;
    #100;
    clk = 1;
    count = count + 1;
    #100;
end

initial begin
    count = 0;
end

endmodule

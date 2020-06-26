`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 02:06:13 PM
// Design Name: 
// Module Name: single_cycle
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


module single_cycle();

reg clk;
reg [31:0] count;
wire [31:0] pc_in;
wire [31:0] pc_out, pc_plus4_out;
wire [4:0] rs1, rs2, rd;
wire [31:0] rs1_out, rs2_out, imm_in, imm_out, alumux1_out, alumux2_out, aluout, dmem_out, wb_out;
wire [31:0] inst;
wire br_eq, br_lt, pcmux_sel, regfilemux_sel, cmpop, alumux1_sel, alumux2_sel, dmem_sel;
wire [2:0] imm_sel, RSel;
wire [3:0] aluop;
wire [1:0] wbmux_sel, WSel;

assign imm_in = inst;
assign rs1 = inst[19:15];
assign rs2 = inst[24:20];
assign rd = inst[11:7];

mux       PCmux(.in0(pc_plus4_out), .in1(aluout), .sel(pcmux_sel), .out(pc_in));
pc        PC   (.clk(clk), .in(pc_in), .out(pc_out));
add_4     PC_4 (.in(pc_out), .out(pc_plus4_out));
IMEM      IMEM (.PC(pc_out), .inst(inst));
regs      REG_FILES (.data_D(wb_out), .addr_D(rd), .addr_A(rs1), 
                    .addr_B(rs2), .Wen(regfilemux_sel), .clk(clk), .data_A(rs1_out), .data_B(rs2_out));
imm_gen   IMM_G( .ImmSel(imm_sel), .inst(inst), .imm(imm_out));
branch_comp branch_comp(.inA(rs1_out), .inB(rs2_out), .BrEq(br_eq), .BrLT(br_lt), .BrUn(cmpop));
mux       ALUmux1(.in0(rs1_out), .in1(pc_out), .sel(alumux1_sel), .out(alumux1_out));
mux       ALUmux2(.in0(rs2_out), .in1(imm_out), .sel(alumux2_sel), .out(alumux2_out));
ALU       ALU(.in1(alumux1_out), .in2(alumux2_out), .out(aluout), .sel(aluop));
dmem      DMEM(.addr(aluout), .dataw(rs2_out), .datar(dmem_out), .clk(clk), .Wen(dmem_sel), .RSel(RSel), .WSel(WSel));
mux4      Wbmux(.in0(dmem_out), .in1(aluout), .in2(pc_plus4_out), .in3(32'd0), .out(wb_out), .sel(wbmux_sel));
control   Control(
    .inst(inst),
    .BrEq(br_eq),
    .BrLT(br_lt),
    .PCSel(pcmux_sel),
    .ImmSel(imm_sel),
    .RegWen(regfilemux_sel),
    .BrUn(cmpop),
    .BSel(alumux2_sel),
    .ASel(alumux1_sel),
    .ALUSel(aluop),
    .MemRW(dmem_sel),
    .WBSel(wbmux_sel),
    .RSel(RSel),
    .WSel(WSel)
    );

always
begin
    clk = 0;
    #10;
    clk = 1;
    count = count + 1;
    #10;
end
initial begin
    count <= 0;
end

endmodule

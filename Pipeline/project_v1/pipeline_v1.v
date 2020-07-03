`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/02/2020 05:09:29 PM
// Design Name: 
// Module Name: pipeline_v1
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


module pipeline_v1();

// ---------------- Define zone ---------------//

parameter ADD = 4'd0;

reg clk;
reg [31:0] count;

wire [31:0] pc_in, pc_plus4_out, pcF, pcD, pcX, pcM, pcM_4, pcW;
wire [31:0] instF, instD, instX, instM, instW;
reg stallF, stallD, stallX, stallM, stallW;
wire [31:0] immF, immD, immX, immM, immW;

// F
wire [2:0] PCSel_F_out, imm_sel;
wire [31:0] PC_Imm_F;
// D
wire [4:0] rsAD, rsBD;
wire [31:0] rsAD_out, rsBD_out, Abypass_out, Bbypass_out, alumuxA_out, alumuxB_out, PC_Imm_D;
wire [1:0] Abypass_sel, Bbypass_sel;
wire alumuxA_sel, alumuxB_sel, br_eq_D, br_lt_D, br_un_D;
// X
wire [31:0] Bbypass_out_X, alumuxA_out_X, alumuxB_out_X, ALUout_X;
wire [3:0] ALUop_X;
// M
wire [31:0] ALUout_M, Bbypass_out_M, dmem_out_M, wb_out_M;
wire dmem_sel_M;
wire [1:0] WSel_M, wbmux_sel_M;
wire [2:0] RSel_M;

// W
wire [4:0] rdW;
wire [31:0] wb_outW;
wire RegWen_W;

// Pipeline signal
reg validF, validD, validX, validM, validW;
wire PCSel_F, PCSel_D, killD_req_next, killX_req_next;
wire stallF_req;

// ---------------- Define zone ---------------//


// F stage

mux8       PCmux(
    .in0(pc_plus4_out),  // 0: PC + 4
    .in1(PC_Imm_F),      // 1: PCF + ImmF
    .in2(ALUout_X),      // 2: JALR -> ALUout_X
    .in3(PC_Imm_D),      // 3: Branch PCD + ImmD
    .in4(),
    .in5(),
    .in6(),
    .in7(),
    .sel(PCSel_F_out), 
    .out(pc_in)
    );

pipeline_reg        PCF   (.clk(clk), .in(pc_in), .out(pcF), .stall(stallF_req));  // Stage register


add_4     PC_4 (.in(pcF), .out(pc_plus4_out));
IMEM      IMEM (.PC(pcF), .inst(instF));
imm_gen   IMM_G( .ImmSel(imm_sel), .inst(instF), .imm(immF));
ALU       ALU_J(.in1(pcF), .in2(immF), .out(PC_Imm_F), .sel(ADD));

// D stage

pipeline_reg        PCD_reg   (.clk(clk), .in(pcF),   .out(pcD),   .stall(stallD));  // Stage register
pipeline_reg        instD_reg (.clk(clk), .in(instF), .out(instD), .stall(stallD));  // Stage register
pipeline_reg        immD_reg  (.clk(clk), .in(immF),  .out(immD),  .stall(stallD));  // Stage register
pipeline_reg        branch_reg(.clk(clk), .in(PC_Imm_F),  .out(PC_Imm_D),  .stall(stallD));

assign rsAD = instD[19:15];
assign rsBD = instD[24:20];

regs      REG_FILES (.addr_D(rdW), .data_D(wb_outW),  
                    .addr_A(rsAD), .data_A(rsAD_out),
                    .addr_B(rsBD), .data_B(rsBD_out),
                    .Wen(RegWen_W & validW), 
                    .clk(clk) );

                            /*
                                bypass option:
                                0: Not bypass
                                1: Forward X -> D ---- ALUout_X
                                2: Forward M -> D ---- wb_out_M
                                3: Forward W -> D ---- wb_outW
                            */

mux4      Abypass(
    .in0(rsAD_out),
    .in1(ALUout_X),
    .in2(wb_out_M),
    .in3(wb_outW),
    .sel(Abypass_sel),
    .out(Abypass_out)
);
mux4      Bbypass(
    .in0(rsBD_out),
    .in1(ALUout_X),
    .in2(wb_out_M),
    .in3(wb_outW),
    .sel(Bbypass_sel),
    .out(Bbypass_out)
);

                                /*
                                    ALU mux: same as single stage
                                */

mux       ALUmuxA(.in0(Abypass_out), .in1(pcD), .sel(alumuxA_sel), .out(alumuxA_out));
mux       ALUmuxB(.in0(Bbypass_out), .in1(immD), .sel(alumuxB_sel), .out(alumuxB_out));

branch_comp branch_comp(.inA(Abypass_out), .inB(Bbypass_out), 
                        .BrEq(br_eq_D), .BrLT(br_lt_D), .BrUn(br_un_D));

// X stage
pipeline_reg        PCX_reg   (.clk(clk), .in(pcD),   .out(pcX),   .stall(stallX));  // Stage register
pipeline_reg        instX_reg (.clk(clk), .in(instD), .out(instX), .stall(stallX));  // Stage register
pipeline_reg        immX_reg  (.clk(clk), .in(immD),  .out(immX),  .stall(stallX));  // Stage register
pipeline_reg        ALUAX_reg (.clk(clk), .in(alumuxA_out),  .out(alumuxA_out_X),  .stall(stallX));
pipeline_reg        ALUBX_reg (.clk(clk), .in(alumuxB_out),  .out(alumuxB_out_X),  .stall(stallX));
pipeline_reg        BoutX_reg (.clk(clk), .in(Bbypass_out),  .out(Bbypass_out_X),  .stall(stallX));

ALU       ALU(.in1(alumuxA_out_X), .in2(alumuxB_out_X), .out(ALUout_X), .sel(ALUop_X));


// M stage

pipeline_reg        PCM_reg   (.clk(clk), .in(pcX),   .out(pcM),   .stall(stallM));  // Stage register
pipeline_reg        instM_reg (.clk(clk), .in(instX), .out(instM), .stall(stallM));  // Stage register
pipeline_reg        immM_reg  (.clk(clk), .in(immX),  .out(immM),  .stall(stallM));  // Stage register
pipeline_reg        ALUM_reg  (.clk(clk), .in(ALUout_X),  .out(ALUout_M),  .stall(stallM));
pipeline_reg        BoutM_reg (.clk(clk), .in(Bbypass_out_X),  .out(Bbypass_out_M),  .stall(stallM));

add_4     PC_4_W (.in(pcM), .out(pcM_4));
dmem      DMEM(.addr(ALUout_M), .dataw(Bbypass_out_M), .datar(dmem_out_M), .clk(clk), .Wen(dmem_sel_M & validM), .RSel(RSel_M), .WSel(WSel_M));
mux4      Wbmux(.in0(dmem_out_M), .in1(ALUout_M), .in2(pcM_4), .in3(32'd0), .out(wb_out_M), .sel(wbmux_sel_M));

// W stage
pipeline_reg        PCW_reg   (.clk(clk), .in(pcM),   .out(pcW),   .stall(stallW));   // Stage register
pipeline_reg        instW_reg (.clk(clk), .in(instM), .out(instW), .stall(stallW));   // Stage register
pipeline_reg        immW_reg  (.clk(clk), .in(immM),  .out(immW),  .stall(stallW));   // Stage register
pipeline_reg        wb_W_reg  (.clk(clk), .in(wb_out_M),  .out(wb_outW),  .stall(stallW));

assign rdW = instW[11:7];

// -------------------------- Each stage control logic -------------------------------- // 


control   ControlF(
// F signal
    .PCSel(PCSel_F), // Branch predict
    .inst(instF),
    .ImmSel(imm_sel)
    );
control   ControlD(
// F signal
    .PCSel(PCSel_D),
    .inst(instD),
// D signal
    .BrEq(br_eq_D),
    .BrLT(br_lt_D),
    .BrUn(br_un_D),
    .BSel(alumuxB_sel),
    .ASel(alumuxA_sel)
    );
control   ControlX(
// F signal
    .inst(instX),
// X signal
    .ALUSel(ALUop_X)
    );
control   ControlM(
// F signal
    .inst(instM),
// M signal
    .MemRW(dmem_sel_M),
    .RSel(RSel_M),
    .WSel(WSel_M),
    .WBSel(wbmux_sel_M)
    );
control   ControlW(
// F signal
    .inst(instW),
// W signal
    .RegWen(RegWen_W)
    );
// -------------------------- Each stage control logic -------------------------------- // 



pipeline_branch pipeline_branch(
    .instF(instF),
    .instD(instD),
    .instX(instX),
    .validF(validF),
    .validD(validD),
    .validX(validX),
    .killD_req_next(killD_req_next),
    .killX_req_next(killX_req_next),
    .PCSel_F(PCSel_F),
    .PCSel_D(PCSel_D),
    .PCSel_F_out(PCSel_F_out)
    );

forwading_pipeline forwading_pipeline(
    .instD(instD),
    .instX(instX),
    .instM(instM),
    .instW(instW),
    .validD(validD),
    .validX(validX),
    .validM(validM),
    .validW(validW),
    .Abypass_sel(Abypass_sel),
    .Bbypass_sel(Bbypass_sel),
    .stallF_req(stallF_req)
    );
always @(posedge clk)
begin
//    stallF <= stallF_req;
//    stallD <= 1'b0;
//    stallX <= 1'b0;
//    stallM <= 1'b0;
//    stallW <= 1'b0;
    
    validF <= 1'b1;
    if ((stallF_req == 1'b1) || (killD_req_next == 1'b1))
    begin
        validD <= 1'b0;
    end else begin
        validD <= validF;
    end
    if (killX_req_next == 1'b1) begin
        validX <= 1'b0;
    end else begin
        validX <= validD;
    end
    validM <= validX;
    validW <= validM;
end

always
begin
    clk = 0;
    #100;
    clk = 1;
    count = count + 1;
    #100;
end
initial begin
    count <= 0;
    stallF<= 0; 
    stallD<= 0;
    stallX<= 0;
    stallM<= 0;
    stallW<= 0;
    validF<= 1;
    validD<= 1;
    validX <=1;
    validM <=1;
    validW <=1;
end

endmodule

// control   ControlW(
// // F signal
//     .PCSel(),
//     .inst(instW),
//     .ImmSel(),
// // D signal
//     .BrEq(),
//     .BrLT(),
//     .BrUn(),
//     .BSel(),
//     .ASel(),
// // X signal
//     .ALUSel(),
// // M signal
//     .MemRW(),
//     .WBSel(),
//     .RSel(),
//     .WSel(),
// // W signal
//     .RegWen(RegWen_W)
//     );

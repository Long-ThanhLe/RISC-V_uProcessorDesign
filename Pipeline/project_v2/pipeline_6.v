`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2020 07:13:09 PM
// Design Name: 
// Module Name: pipeline_6
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


module pipeline_6();

wire [31:0] instF, instD, instD2, instX, instM, instW;
wire [31:0] pc_in, pcF, pcD, pcD2, pcX, pcM, pcW;
reg clk;

parameter ADD = 4'd0;

// F stage
wire stallF_req, PCSel_F;
wire [31:0] pc_plus4_out, immF, PC_Imm_F;
wire [2:0] imm_sel;
wire [2:0] PCSel_F_out;

// D stage
wire [4:0] rsAD, rsBD;
wire [31:0] rsA_out, rsB_out, PC_Imm_D, pcD_4, immD;
reg stallD;
// D2 stage
wire br_eq_D2, br_lt_D2, br_un_D2, BSel, ASel, PCSel_D2;
reg stallD2;
wire [31:0] Bout_D2, Aout_D2, Bbypass_out, Abypass_out, PC_Imm_D2, immD2, rsB_out_D2, rsA_out_D2, pcD2_4;
wire [1:0] Abypass_sel, Bbypass_sel;
// X stage
wire [31:0] Aout_X, Bout_X, ALUout_X, Bbypass_out_X, pcX_4;
wire [3:0] ALUSel;
reg stallX;

//M stage
wire [31:0] wbout_M, dmem_out_M, Bbypass_out_M, ALUout_M, pcM_4;
wire [1:0] WBSel, WSel;
wire DMEM_Wen;
wire [2:0] RSel ;
reg stallM;

//W stage
wire [31:0] wbout_W;
wire [4:0] rdW;
wire RegWen;
reg stallW;

// Pipeline signals
reg validF, validD, validD2, validX, validM, validW;
wire killD_req_next, killD2_req_next, killX_req_next;

    // 0: PC + 4
    // 1: PCF + ImmF
    // 2: JALR -> ALUout_X
    // 3: Branch PCD2 + ImmD2
    // 4: Branch PCD2 + 4

mux8 PCmux(
    .in0(pc_plus4_out),
    .in1(PC_Imm_F),
    .in2(ALUout_X),
    .in3(PC_Imm_D2),
    .in4(pcD2_4),
    .in5(),
    .in6(),
    .in7(),
    .sel(PCSel_F_out),
    .out(pc_in)
);

pipeline_reg   PCF   (.clk(clk), .in(pc_in), .out(pcF), .stall(stallF_req));  // Stage register

add_4          PC_F4(.in(pcF), .out(pc_plus4_out));
IMEM           IMEM (.PC(pcF), .inst(instF));
imm_gen        IMM_G( .ImmSel(imm_sel), .inst(instF), .imm(immF));
ALU            ALU_J(.in1(pcF), .in2(immF), .out(PC_Imm_F), .sel(ADD)); 

// D stage

pipeline_reg   branchD_reg(.clk(clk), .in(PC_Imm_F),      .out(PC_Imm_D),  .stall(stallD));
pipeline_reg   ImmD_reg   (.clk(clk), .in(pc_plus4_out),  .out(pcD_4),     .stall(stallD));
pipeline_reg   PCD_reg    (.clk(clk), .in(pcF),           .out(pcD),       .stall(stallD));  // Stage register
pipeline_reg   instD_reg  (.clk(clk), .in(instF),         .out(instD),     .stall(stallD));  // Stage register
pipeline_reg   immD_reg   (.clk(clk), .in(immF),          .out(immD),      .stall(stallD));  // Stage register

assign rsAD = instD[19:15];
assign rsBD = instD[24:20];
regs      REG_FILES (.addr_D(rdW), .data_D(wbout_W),  
                    .addr_A(rsAD), .data_A(rsA_out),
                    .addr_B(rsBD), .data_B(rsB_out),
                    .Wen(RegWen & validW), 
                    .clk(clk) );

// D2 stage

pipeline_reg   branch_reg(.clk(clk), .in(PC_Imm_D),  .out(PC_Imm_D2),   .stall(stallD2));
pipeline_reg   Imm_reg_D2(.clk(clk), .in(pcD_4),     .out(pcD2_4),      .stall(stallD2));
pipeline_reg   rsA_outD2 (.clk(clk), .in(rsA_out),   .out(rsA_out_D2),  .stall(stallD2));
pipeline_reg   rsB_outD2 (.clk(clk), .in(rsB_out),   .out(rsB_out_D2),  .stall(stallD2));
pipeline_reg   ImmD2_reg (.clk(clk), .in(immD),      .out(immD2),       .stall(stallD2));  // Stage register
pipeline_reg   PCD2_reg  (.clk(clk), .in(pcD),       .out(pcD2),        .stall(stallD2));  // Stage register
pipeline_reg   instD2_reg(.clk(clk), .in(instD),     .out(instD2),      .stall(stallD2));  // Stage register

                            /*
                                bypass option:
                                0: Not bypass
                                1: Forward X -> D2 ---- ALUout_X
                                2: Forward M -> D2 ---- wbout_M
                                3: Forward W -> D2 ---- wbout_W
                            */

mux4 Abypass_mux (
    .in0(rsA_out_D2),
    .in1(ALUout_X),
    .in2(wbout_M),
    .in3(wbout_W),
    .sel(Abypass_sel),
    .out(Abypass_out)
);

mux4 Bbypass_mux (
    .in0(rsB_out_D2),
    .in1(ALUout_X),
    .in2(wbout_M),
    .in3(wbout_W),
    .sel(Bbypass_sel),
    .out(Bbypass_out)
);

mux Aout(
    .in0(Abypass_out),
    .in1(pcD2),
    .sel(ASel),
    .out(Aout_D2)
);

mux Bout(
    .in0(Bbypass_out),
    .in1(immD2),
    .sel(BSel),
    .out(Bout_D2)
);

branch_comp branch_comp(.inA(Abypass_out), .inB(Bbypass_out), 
                        .BrEq(br_eq_D2), .BrLT(br_lt_D2), .BrUn(br_un_D2));

// X stage
pipeline_reg   PCX_4_reg (.clk(clk), .in(pcD2_4),        .out(pcX_4),          .stall(stallX));  
pipeline_reg   Aout_X_reg(.clk(clk), .in(Aout_D2),       .out(Aout_X),         .stall(stallX));
pipeline_reg   Bout_X_reg(.clk(clk), .in(Bout_D2),       .out(Bout_X),         .stall(stallX));
pipeline_reg   rsB_outX  (.clk(clk), .in(Bbypass_out),   .out(Bbypass_out_X),  .stall(stallX));
pipeline_reg   PCX_reg   (.clk(clk), .in(pcD2),          .out(pcX),            .stall(stallX));  // Stage register
pipeline_reg   instX_reg (.clk(clk), .in(instD2),        .out(instX),          .stall(stallX));  // Stage register

ALU            ALU(.in1(Aout_X), .in2(Bout_X), .out(ALUout_X), .sel(ALUSel));

// M stage

pipeline_reg   Imm_reg_M (.clk(clk), .in(pcX_4),         .out(pcM_4),          .stall(stallM));
pipeline_reg   rsA_outM  (.clk(clk), .in(ALUout_X),      .out(ALUout_M),       .stall(stallM));
pipeline_reg   rsB_outM  (.clk(clk), .in(Bbypass_out_X), .out(Bbypass_out_M),  .stall(stallM));
pipeline_reg   PCM_reg   (.clk(clk), .in(pcX),           .out(pcM),            .stall(stallM));  // Stage register
pipeline_reg   instM_reg (.clk(clk), .in(instX),         .out(instM),          .stall(stallM));  // Stage register

dmem      DMEM(.addr(ALUout_M), .dataw(Bbypass_out_M), .datar(dmem_out_M), .clk(clk), .Wen(DMEM_Wen & validM), .RSel(RSel), .WSel(WSel));
mux4      Wbmux(.in0(dmem_out_M), .in1(ALUout_M), .in2(pcM_4), .in3(32'd0), .out(wbout_M), .sel(WBSel));

// W stage
pipeline_reg   instW_reg (.clk(clk), .in(wbout_M),       .out(wbout_W),          .stall(stallW));  // Stage register
pipeline_reg   rsB_outW  (.clk(clk), .in(instM),         .out(instW),            .stall(stallW));

assign rdW = instW[11:7];

// -------------------------- Each stage control logic -------------------------------- // 


control   ControlF(
// F signal
    .PCSel(PCSel_F), // Branch predict
    .inst(instF),
    .ImmSel(imm_sel)
    );
//control   ControlD(
//// F signal
//    .inst(instD)
//    );
control   ControlD2(
// F signal
    .PCSel(PCSel_D2),
    .inst(instD2),
// D2 signal
    .BrEq(br_eq_D2),
    .BrLT(br_lt_D2),
    .BrUn(br_un_D2),
    .BSel(BSel),
    .ASel(ASel)
    );
control   ControlX(
// F signal
    .inst(instX),
// X signal
    .ALUSel(ALUSel)
    );
control   ControlM(
// F signal
    .inst(instM),
// M signal
    .MemRW(DMEM_Wen),
    .RSel(RSel),
    .WSel(WSel),
    .WBSel(WBSel)
    );
control   ControlW(
// F signal
    .inst(instW),
// W signal
    .RegWen(RegWen)
    );
// -------------------------- Each stage control logic -------------------------------- // 

// Pipeline Control Logic

pipeline6_branch pipeline_branch(
    .clk(clk),
    .instF(instF),
    .instD(instD),
    .instD2(instD2),
    .instX(instX),
    .validF(validF),
    .validD(validD),
    .validD2(validD2),
    .validX(validX),
    .killD_req_next(killD_req_next),
    .killD2_req_next(killD2_req_next),
    .killX_req_next(killX_req_next),
    .PCSel_F(PCSel_F),
    .PCSel_D2(PCSel_D2),
    .PCSel_F_out(PCSel_F_out)
    );

forwarding_pipeline6 forwarding_pipeline6(
    .instF(instF),
    .instD(instD),
    .instD2(instD2),
    .instX(instX),
    .instM(instM),
    .instW(instW),
    .validF(validF),
    .validD(validD),
    .validD2(validD2),
    .validX(validX),
    .validM(validM),
    .validW(validW),
    .Abypass_sel(Abypass_sel),
    .Bbypass_sel(Bbypass_sel),
    .stallF_req(stallF_req)
    );

always @(posedge clk) begin
    validF <= 1'b1;
    if ((stallF_req == 1'b1) || (killD_req_next == 1'b1))
    begin
        validD <= 1'b0;
    end else begin
        validD <= validF;
    end
    if (killD2_req_next == 1'b1) begin
        validD2 <= 1'b0;
    end else begin
        validD2 <= validD;
    end
    if (killX_req_next == 1'b1) begin
        validX <= 1'b0;
    end else begin
        validX <= validD2;
    end
    validM <= validX;
    validW <= validM;
end

always
begin
    #100;
    clk=1;
    #100;
    clk=0;
end
initial begin
//    stallF <= 0;
    stallD <= 0;
    stallD2<= 0;
    stallX <= 0;
    stallM <= 0;
    stallW <= 0;
    
    validF <= 1;
    validD <= 1;
    validD2<= 1;
    validX <= 1;
    validM <= 1;
    validW <= 1;
end
endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2020 06:38:04 PM
// Design Name: 
// Module Name: stall_bypass
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


module stall_bypass(
    instF,
    instD,
    instE,
    instM, 
    instW,
    stall,
    alumux1,
    alumux2,
    ASrc,
    BSrc
    );
input alumux1, alumux2;
input [31:0] instF, instD, instE, instM, instW;
output reg [2:0] BSrc;
output reg [2:0] ASrc;
output reg stall;

parameter IMM_R_TYPE = 5'b01100;
parameter IMM_B_TYPE = 5'b11000;
parameter IMM_I_CAL = 5'b00100;
parameter IMM_I_LOAD = 5'b00000;
parameter IMM_S_TYPE = 5'b01000;
parameter IMM_LUI_TYPE = 5'b01101;
parameter IMM_AUIPC_TYPE = 5'b00101;
parameter IMM_JAL_TYPE = 5'b11011;
parameter IMM_JALR_TYPE = 5'b11001;

wire stall_load, stall_total;
wire bypassA, bypassB, bypassA_M, bypassB_M;

wire re1D, re2D;
wire we_bypassE, we_stallE;
wire we_bypassM, we_stallM, re1M, re2M, we_bypassD;
wire we_bypassW, we_stallW, re1W, re2W, we_stallD;
wire re1E, re2E;

wire [4:0] rs1D, rs2D, rs1E, rs2E; 
wire [4:0] wsE, wsM, wsD;
wire [4:0] rs1M, rs2M;
wire [4:0] wsW, rs1W, rs2W;

w wD(.inst(instD), .we_bypass(we_bypassD), .we_stall(we_stallD), .ws(wsD));
w wE(.inst(instE), .we_bypass(we_bypassE), .we_stall(we_stallE), .ws(wsE));
w wM(.inst(instM), .we_bypass(we_bypassM), .we_stall(we_stallM), .ws(wsM));
w wW(.inst(instW), .we_bypass(we_bypassW), .we_stall(we_stallW), .ws(wsW));

r rD(.inst(instD), .re1(re1D), .rs1(rs1D), .re2(re2D), .rs2(rs2D));
r rE(.inst(instE), .re1(re1E), .rs1(rs1E), .re2(re2E), .rs2(rs2E));
r rM(.inst(instM), .re1(re1M), .rs1(rs1M), .re2(re2M), .rs2(rs2M));
r rW(.inst(instW), .re1(re1W), .rs1(rs1W), .re2(re2W), .rs2(rs2W));

// LOAD -> stall one cycle
assign stall_load = ((rs1D == wsE) && ((instE[6:2] == 5'd0) && (instE[14:12] == 3'b010)) && (wsE != 1'b0) && (re1D != 1'b0))
        || ((rs2D == wsE) && ((instE[6:2] == 5'd0) && (instE[14:12] == 3'b010)) && (wsE != 1'b0) && (re2D != 1'b0));

// assign bypassA = (rs1D == wsE) && (we_bypassE == 1'b1) && (re1D == 1'b1);
// assign bypassB =  (rs2D == wsE) && (we_bypassE == 1'b1) && (re2D == 1'b1);
assign bypassA = (rs1E == wsM) && (we_bypassM == 1'b1) && (re1E == 1'b1) && (wsM != 5'd0);
assign bypassB =  (rs2E == wsM) && (we_bypassM == 1'b1) && (re2E == 1'b1) && (wsM != 5'd0);

assign bypassA_M = (rs1E == wsW) && (we_bypassW == 1'b1) && (re1E == 1'b1) && (wsW != 5'd0);
assign bypassB_M = (rs2E == wsW) && (we_bypassW == 1'b1) && (re2E == 1'b1) && (wsW != 5'd0);

// assign stall_add_addi = bypassA | bypassB;
assign stall_total = stall_load ;

always @(*)
begin
    stall = stall_load;
    if (bypassA) begin // Bypass alumux1
        ASrc[0] = alumux1;
        ASrc[2:1] = 2'd1;
    end else begin
        if (bypassA_M) begin
            ASrc[0] = alumux1;
            ASrc[2:1] = 2'd2;
        end else begin
            ASrc[0] = alumux1;
            ASrc[2:1] = 2'd0;       
        end

    end
    if (bypassB) begin // Bypass alumux2
        BSrc[0] = alumux2;
        BSrc[2:1] = 2'd1;
    end else begin
        if (bypassB_M) begin
            BSrc[0] = alumux2;
            BSrc[2:1] = 2'd2;
        end else begin
            BSrc[0] = alumux2;
            BSrc[2:1] = 2'd0;
        end
    end
end

initial begin
    ASrc <= 3'd0;
    BSrc <= 3'd0;
    stall <= 1'b0;
end
    
endmodule

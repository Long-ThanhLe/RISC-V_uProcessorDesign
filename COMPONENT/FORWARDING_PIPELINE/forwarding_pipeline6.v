`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2020 10:54:06 PM
// Design Name: 
// Module Name: forwarding_pipeline6
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


module forwarding_pipeline6(
    instF,
    instD,
    instD2,
    instX,
    instM,
    instW,
    validF,
    validD,
    validD2,
    validX,
    validM,
    validW,
    Abypass_sel,
    Bbypass_sel,
    stallF_req
    );
    
input [31:0] instD, instD2, instX, instM, instW, instF;
input validF, validD, validD2, validX, validM, validW;
output reg stallF_req;
output reg [1:0] Abypass_sel, Bbypass_sel;
//0: Not bypass
//1: Forward X -> D ---- ALUout_X
//2: Forward M -> D ---- wb_out_M
//3: Forward W -> D ---- wb_outW

wire we_bypassF, we_stallF, re1F, re2F;
wire [4:0] rs1F, rs2F, wsF;
w   wF(.inst(instF), .we_bypass(we_bypassF), .we_stall(we_stallF), .ws(wsF));
r   rF(.inst(instF), .re1(re1F), .re2(re2F), .rs1(rs1F), .rs2(rs2F));
wire we_bypassD, we_stallD, re1D, re2D;
wire [4:0] rs1D, rs2D, wsD;
w   wD(.inst(instD), .we_bypass(we_bypassD), .we_stall(we_stallD), .ws(wsD));
r   rD(.inst(instD), .re1(re1D), .re2(re2D), .rs1(rs1D), .rs2(rs2D));
wire we_bypassD2, we_stallD2, re1D2, re2D2;
wire [4:0] rs1D2, rs2D2, wsD2;
w   wD2(.inst(instD2), .we_bypass(we_bypassD2), .we_stall(we_stallD2), .ws(wsD2));
r   rD2(.inst(instD2), .re1(re1D2), .re2(re2D2), .rs1(rs1D2), .rs2(rs2D2));
wire we_bypassX, we_stallX, re1X, re2X;
wire [4:0] rs1X, rs2X, wsX;
w   wX(.inst(instX), .we_bypass(we_bypassX), .we_stall(we_stallX), .ws(wsX));
r   rX(.inst(instX), .re1(re1X), .re2(re2X), .rs1(rs1X), .rs2(rs2X));
wire we_bypassM, we_stallM, re1M, re2M;
wire [4:0] rs1M, rs2M, wsM;
w   wM(.inst(instM), .we_bypass(we_bypassM), .we_stall(we_stallM), .ws(wsM));
r   rM(.inst(instM), .re1(re1M), .re2(re2M), .rs1(rs1M), .rs2(rs2M));
wire we_bypassW, we_stallW, re1W, re2W;
wire [4:0] rs1W, rs2W, wsW;
w   wW(.inst(instW), .we_bypass(we_bypassW), .we_stall(we_stallW), .ws(wsW));
r   rW(.inst(instW), .re1(re1W), .re2(re2W), .rs1(rs1W), .rs2(rs2W));

wire Abypass_XD2, Abypass_MD2, Abypass_WD2;
wire Bbypass_XD2, Bbypass_MD2, Bbypass_WD2;

assign Abypass_XD2 = (rs1D2 == wsX) && (we_bypassX == 1'b1) && (re1D2 == 1'b1) && (wsX != 5'd0) && (validX == 1'b1) && (validD2 == 1'b1);
assign Bbypass_XD2 = (rs2D2 == wsX) && (we_bypassX == 1'b1) && (re2D2 == 1'b1) && (wsX != 5'd0) && (validX == 1'b1) && (validD2 == 1'b1);
assign Abypass_MD2 = (rs1D2 == wsM) && (we_bypassM == 1'b1) && (re1D2 == 1'b1) && (wsM != 5'd0) && (validM == 1'b1) && (validD2 == 1'b1);
assign Bbypass_MD2 = (rs2D2 == wsM) && (we_bypassM == 1'b1) && (re2D2 == 1'b1) && (wsM != 5'd0) && (validM == 1'b1) && (validD2 == 1'b1);
assign Abypass_WD2 = (rs1D2 == wsW) && (we_bypassW == 1'b1) && (re1D2 == 1'b1) && (wsW != 5'd0) && (validW == 1'b1) && (validD2 == 1'b1);
assign Bbypass_WD2 = (rs2D2 == wsW) && (we_bypassW == 1'b1) && (re2D2 == 1'b1) && (wsW != 5'd0) && (validW == 1'b1) && (validD2 == 1'b1);

// Load use - stall
wire stall_load_A, stall_load_B, stall_load;
assign stall_load_B = (rs2F == wsD) && (we_stallD == 1'b1) && (re2F == 1'b1) && (wsD != 5'd0) && (validF == 1'b1) && (validD == 1'b1) ;
assign stall_load_A = (rs1F == wsD) && (we_stallD == 1'b1) && (re1F == 1'b1) && (wsD != 5'd0) && (validF == 1'b1) && (validD == 1'b1) ;
assign stall_load = stall_load_A | stall_load_B;

always @(*)
begin

    if (Abypass_XD2 == 1'b1) begin
        Abypass_sel = 2'd1;
    end else begin 
        if (Abypass_MD2 == 1'b1) begin
            Abypass_sel = 2'd2;        
        end else begin
            if (Abypass_WD2 == 1'b1) begin
                Abypass_sel = 2'd3;
            end else begin
                Abypass_sel = 2'd0;
            end
        end
    end
    
    if (Bbypass_XD2 == 1'b1) begin
        Bbypass_sel = 2'd1;
    end else begin 
        if (Bbypass_MD2 == 1'b1) begin
            Bbypass_sel = 2'd2;        
        end else begin
            if (Bbypass_WD2 == 1'b1) begin
                Bbypass_sel = 2'd3;
            end else begin
                Bbypass_sel = 2'd0;
            end
        end
    end
    
    // Load - use
    if (stall_load == 1'b1)
    begin
        stallF_req = 1'b1;
    end else begin
        stallF_req = 1'b0;
    end
end

endmodule

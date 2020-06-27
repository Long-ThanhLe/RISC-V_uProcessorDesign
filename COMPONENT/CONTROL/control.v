`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/26/2020 02:48:08 PM
// Design Name: 
// Module Name: control
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


module control(
    inst,
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
    
input [31:0] inst;
input BrEq, BrLT;

output reg PCSel, ASel, BSel, MemRW, BrUn, RegWen;
output reg [1:0] WSel, WBSel;
output reg [2:0] RSel, ImmSel;
output reg [3:0] ALUSel;

//output wire PCSel, ASel, BSel, MemRW, BrUn, RegWen;
//output wire [1:0] WSel, WBSel;
//output wire [2:0] RSel, ImmSel;
//output wire [3:0] ALUSel;

//wire [19:0] out;

//assign PCSel <= out[19];
//assign ImmSel <= out[18:16];
//assign RegWen <= out[15];
//assign BrUn <= out[14];
//assign ASel <= out[13];
//assign BSel <= out[12];
//assign ALUSel <= out[11:8];
//assign MemRW <= out[7];
//assign WBSel <= out[6:5];
//assign RSel <= out[4:2];
//assign WSel <= out[1:0];

/*  */

parameter IMM_R_TYPE = 3'd5;
parameter IMM_B_TYPE = 3'd2;
parameter IMM_I_TYPE = 3'd0;
parameter IMM_S_TYPE = 3'd1;
parameter IMM_U_TYPE = 3'd3;
parameter IMM_J_TYPE = 3'd4;

parameter BEQ = 3'b000;
parameter BNE = 3'b001;
parameter BLT = 3'b100;
parameter BGE = 3'b101;
parameter BLTU = 3'b110;
parameter BGEU = 3'b111;

parameter SB = 3'b000;
parameter SH = 3'b001;
parameter SW = 3'b010;

parameter LB = 3'b000;
parameter LH = 3'b001;
parameter LW = 3'b010;
parameter LBU = 3'b100;
parameter LHU = 3'b101;

parameter R_TYPE = 5'b01100;
parameter B_TYPE = 5'b11000;
parameter I_CAL = 5'b00100;
parameter I_LOAD = 5'b00000;
parameter S_TYPE = 5'b01000;
parameter LUI_TYPE = 5'b01101;
parameter AUIPC_TYPE = 5'b00101;
parameter JAL_TYPE = 5'b11011;
parameter JALR_TYPE = 5'b11001;


parameter ADD = 4'd0;
parameter SUB = 4'd1;
parameter XOR = 4'd2;
parameter OR  = 4'd3;
parameter AND = 4'd4;
parameter SLL = 4'd5;
parameter SRL = 4'd6;
parameter SRA = 4'd7;
parameter USLT= 4'd8;
parameter SLT = 4'd9;

initial begin
    PCSel = 1'b0;
    ASel = 1'b0;
    BSel = 1'b0; 
    MemRW = 1'b0;
    BrUn = 1'b0; 
    RegWen = 1'b0;
    WSel = 2'd0; 
    WBSel = 2'd0;
    RSel = 3'd0;
    ImmSel = 3'd0;
    ALUSel = 4'd0;
end

always @(*)
begin

case (inst[6:2])
    R_TYPE:
    begin
        PCSel <= 1'b0; 
        ImmSel <= IMM_R_TYPE;
        RegWen <= 1'b1;
        BSel <= 1'b0;
        ASel <= 1'b0;
        MemRW <= 1'b0;
        WBSel <= 2'd1;
        
        case (inst[14:12])
        3'b000: // ADD + SUB
            case (inst[30])
            1'b0: ALUSel <= ADD; // ADD
            1'b1: ALUSel <= SUB; // SUB
            endcase
        3'b001: ALUSel <= SLL; // SLL
        3'b010: ALUSel <= SLT; //SLT
        3'b011: ALUSel <= USLT; // SLTU
        3'b100: ALUSel <= XOR; // X?
        3'b101: 
            case(inst[30])
            1'b0: ALUSel <= SRL;  // SRL
            1'b1: ALUSel <= SRA; // SRA
            endcase
        3'b110: ALUSel <= OR; // OR
        3'b111: ALUSel <= AND; // AND
        endcase
    end
    I_CAL:
    begin
        PCSel <= 1'b0;
        ImmSel <= IMM_I_TYPE;
        RegWen <= 1'b1;
        BSel <= 1'b1;
        ASel <= 1'b0;
        MemRW <= 1'b0;
        WBSel <= 2'd1;
        
        case (inst[14:12])
        3'b000: ALUSel <= ADD; // addi
        3'b010: ALUSel <= SLT; // slti
        3'b011: ALUSel <= USLT; // sltiu
        3'b100: ALUSel <= XOR; // xori
        3'b110: ALUSel <= OR; //ori
        3'b101: 
            case(inst[30])
            1'b0: ALUSel <= SRL; // srli
            1'b1: ALUSel <= SRA; // srai
            endcase
        3'b001: ALUSel <= SLL; // slli
        3'b111: ALUSel <= AND; // andi
        endcase
    end
    B_TYPE:
    begin
        MemRW <= 1'b0;
        ALUSel <= ADD;
        ASel <= 1'b1;
        BSel <= 1'b1;
        RegWen <= 1'b0;
        ImmSel <= IMM_B_TYPE;
        case (inst[14:12])
        BEQ:
        begin
            BrUn <= 1'b0;
            PCSel <= BrEq;
        end
        BNE:
        begin
            BrUn <= 1'b0;
            PCSel <= ~BrEq;
        end
        BLT:
        begin
            BrUn <= 1'b0;
            PCSel <= BrLT;
        end
        BGE:
        begin
            BrUn <= 1'b0;
            PCSel <= ~BrLT;
            
        end
        BLTU:
        begin
            BrUn <= 1'b1;
            PCSel <= BrLT;
        end
        BGEU:
        begin
            BrUn <= 1'b1;
            PCSel <= ~BrLT;
        end
        endcase
    end
    I_LOAD:
    begin
        PCSel <= 1'b0;
        ImmSel <= IMM_I_TYPE;
        RegWen <= 1'b1;
        BSel <= 1'b1;
        ASel <= 1'b0;
        MemRW <= 1'b0;
        WBSel <= 2'd0;
        ALUSel <= ADD;
        case (inst[14:12])
        LB: RSel <= 3'd2;
        LH: RSel <= 3'd1;
        LW: RSel <= 3'd0;
        LBU: RSel <= 3'd4;
        LHU: RSel <= 3'd3;
        endcase
    end
    S_TYPE:
    begin
        PCSel <= 1'b0;
        ImmSel <= IMM_S_TYPE;
        RegWen <= 1'b0;
        BSel <= 1'b1;
        ASel <= 1'b0;
        MemRW <= 1'b1;
        ALUSel <= ADD;
        case (inst[14:12])
        SB: WSel <= 2'd2;
        SH: WSel <= 2'd1;
        SW: WSel <= 2'd0;
        endcase
    end
    LUI_TYPE:
    begin
    end
    AUIPC_TYPE:
    begin
    end
    JAL_TYPE:
    begin
        PCSel <= 1'b1;
        ImmSel <= IMM_J_TYPE;
        RegWen <= 1'b1;
        BSel <= 1'b1;
        ASel <= 1'b1;
        MemRW <= 1'b0;
        WBSel <= 2'd2;
        ALUSel <= ADD;
    end
    JALR_TYPE:
    begin
        PCSel <= 1'b1;
        ImmSel <= IMM_I_TYPE;
        RegWen <= 1'b1;
        BSel <= 1'b1;
        ASel <= 1'b0;
        MemRW <= 1'b0;
        WBSel <= 2'd2;
        ALUSel <= ADD;
    end
    default:
    begin
        MemRW <= 1'b0;
    end

endcase
end

endmodule

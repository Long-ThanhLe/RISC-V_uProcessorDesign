`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/06/2020 10:51:09 PM
// Design Name: 
// Module Name: pipeline6_branch
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


module pipeline6_branch(
    clk,
    instF,
    instD,
    instD2,
    instX,
    validF,
    validD,
    validD2,
    validX,
    killD_req_next,
    killD2_req_next,
    killX_req_next,
    PCSel_F,
    PCSel_D2,
    PCSel_F_out
);
input [31:0] instF, instD, instD2, instX;
input validF, validD, validD2, validX, PCSel_F, PCSel_D2, clk;
output reg killD_req_next, killD2_req_next;
output reg killX_req_next;
output reg [2:0] PCSel_F_out;

parameter R_TYPE = 5'b01100;
parameter B_TYPE = 5'b11000;
parameter I_CAL = 5'b00100;
parameter I_LOAD = 5'b00000;
parameter S_TYPE = 5'b01000;
parameter LUI_TYPE = 5'b01101;
parameter AUIPC_TYPE = 5'b00101;
parameter JAL_TYPE = 5'b11011;
parameter JALR_TYPE = 5'b11001;

// Bug
reg [15:0] kt;
// Branch & JAL & JALR

reg [1:0] state;
/*
0: Hard Jump
1: Soft Jump
2: Hard Not Jump
3: Soft Not Jump
*/
reg predict_not_jump;
reg return_jump;
reg return_valid;
always @(*)
begin

case ({{validD2}, {validX}})
2'b00: begin
    return_valid = 1'b0;
    case (instF[6:2])
    JAL_TYPE: begin
        kt = 1;
        killD_req_next = 1'b0;
        killD2_req_next = 1'b0;
        killX_req_next = 1'b0;
        PCSel_F_out = 3'd1; // PCF + ImF
    end
    JALR_TYPE: begin
        kt = 2;
        killD_req_next = 1'b0;
        killD2_req_next = 1'b0;
        killX_req_next = 1'b0;
        PCSel_F_out = 3'd0; // PCF + 4 // Guest
    end
    B_TYPE: begin
        kt = 3;
        PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
        killD_req_next = 1'b0;
        killD2_req_next = 1'b0;
        killX_req_next = 1'b0;
        
    end
    default: begin
        killD_req_next = 1'b0;
        killD2_req_next = 1'b0;
        killX_req_next = 1'b0;
        
        // PCF next
        if (PCSel_F == 1'b0) begin
            kt = 5;
            PCSel_F_out = 3'd0; 
        end else begin
            kt = 6;
            PCSel_F_out = 3'd1; 
        end
    end
    endcase
end
2'b01: begin
    return_valid = 1'b0;
    case (instX[6:2])
    JALR_TYPE: begin
        kt = 7;
        killD_req_next = 1'b1;
        killD2_req_next = 1'b1;
        killX_req_next = 1'b1;
        PCSel_F_out = 3'd2; // ALUoutX
    end
    default: begin
        case (instF[6:2])
        JAL_TYPE: begin
            kt = 8;
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
            PCSel_F_out = 3'd1; // PC + ImF
        end
        JALR_TYPE: begin
            kt = 9;
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
            PCSel_F_out = 3'd0; // PC + 4 // Guest
        end
        B_TYPE: begin
            kt = 10;
            PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
        end
        default: begin
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
            
            // PCF next
            if (PCSel_F == 1'b0) begin
                kt = 11;
                PCSel_F_out = 3'd0; 
            end else begin
                kt = 12;
                PCSel_F_out = 3'd1; 
            end
        end
        endcase
    end
    endcase
end
2'b10: begin
    case (instD2[6:2])
    B_TYPE: begin
        return_valid = 1'b1;
        if (PCSel_D2 == 1'b1) begin // Return Jump
            return_jump = 1'b1;
            kt = 13;
            if (predict_not_jump == 1'b1) begin 
                killD_req_next = 1'b1;
                killD2_req_next = 1'b1;
                killX_req_next = 1'b0;
                PCSel_F_out = 3'd3; // PCD + ImmD
            end else begin
                case (instF[6:2])
                JAL_TYPE: begin
                    kt = 14;
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                    PCSel_F_out = 3'd1; // PC + ImF
                end
                JALR_TYPE: begin
                    kt = 15;
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                    PCSel_F_out = 3'd0; // PC + 4 // Guest
                end
                B_TYPE: begin
                    kt = 16;
                    PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                end
                default: begin
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                    
                    // PCF next
                    if (PCSel_F == 1'b0) begin
                        kt = 17;
                        PCSel_F_out = 3'd0; 
                    end else begin
                        kt = 18;
                        PCSel_F_out = 3'd1; 
                    end
                end
                endcase 
            end
        end else begin // Return Not Jump
            return_jump = 1'b0;
            if (predict_not_jump == 1'b1) begin
                case (instF[6:2])
                JAL_TYPE: begin
                    kt = 14;
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                    PCSel_F_out = 3'd1; // PC + ImF
                end
                JALR_TYPE: begin
                    kt = 15;
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                    PCSel_F_out = 3'd0; // PC + 4 // Guest
                end
                B_TYPE: begin
                    kt = 16;
                    PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                end
                default: begin
                    killD_req_next = 1'b0;
                    killD2_req_next = 1'b0;
                    killX_req_next = 1'b0;
                    
                    // PCF next
                    if (PCSel_F == 1'b0) begin
                        kt = 17;
                        PCSel_F_out = 3'd0; 
                    end else begin
                        kt = 18;
                        PCSel_F_out = 3'd1; 
                    end
                end
                endcase
            end else begin // Predict Jump
                killD_req_next = 1'b1;
                killD2_req_next = 1'b1;
                killX_req_next = 1'b0;
                PCSel_F_out = 3'd4; // PCD + 4
            end
        end
    end
    default: begin
        return_valid = 1'b0;
        case (instF[6:2])
        JAL_TYPE: begin
            kt = 19;
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
            PCSel_F_out = 3'd1; // PC + ImF
        end
        JALR_TYPE: begin
            kt = 20;
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
            PCSel_F_out = 3'd0; // PC + 4 // Guest
        end
        B_TYPE: begin
            kt = 21;
            PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
        end
        default: begin
            killD_req_next = 1'b0;
            killD2_req_next = 1'b0;
            killX_req_next = 1'b0;
            
            // PCF next
            if (PCSel_F == 1'b0) begin
                kt = 22;
                PCSel_F_out = 3'd0; 
            end else begin
                kt = 23;
                PCSel_F_out = 3'd1; 
            end
        end
        endcase
    end
    endcase
end
2'b11: begin
case (instX[6:2])
    JALR_TYPE: begin
        return_valid = 1'b0;
        kt = 24;
        killD_req_next = 1'b1;
        killD2_req_next = 1'b1;
        killX_req_next = 1'b1;
        PCSel_F_out = 3'd2; // ALUoutX
    end
    default: begin
        case (instD2[6:2])
        B_TYPE: begin
            return_valid = 1'b1;
            if (PCSel_D2 == 1'b1) begin // return jump
                return_jump = 1'b1;
                kt = 25;
                if (predict_not_jump == 1'b1) begin
                    killD_req_next = 1'b1;
                    killD2_req_next = 1'b1;
                    killX_req_next = 1'b0;
                    PCSel_F_out = 3'd3; // PCD + ImmD
                end else begin
                    case (instF[6:2])
                    JAL_TYPE: begin
                        kt = 26;
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                        PCSel_F_out = 3'd1; // PC + ImF
                    end
                    JALR_TYPE: begin
                        kt = 27;
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                        PCSel_F_out = 3'd0; // PC + 4 // Guest
                    end
                    B_TYPE: begin
                        kt = 28;
                        PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                    end
                    default: begin
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                        
                        // PCF next
                        if (PCSel_F == 1'b0) begin
                            kt = 29;
                            PCSel_F_out = 3'd0; 
                        end else begin
                            kt = 30;
                            PCSel_F_out = 3'd1; 
                        end
                    end
                    endcase
                end
            end else begin // return not jump
                return_jump = 1'b0;
                if (predict_not_jump == 1'b1) begin
                    case (instF[6:2])
                    JAL_TYPE: begin
                        kt = 26;
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                        PCSel_F_out = 3'd1; // PC + ImF
                    end
                    JALR_TYPE: begin
                        kt = 27;
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                        PCSel_F_out = 3'd0; // PC + 4 // Guest
                    end
                    B_TYPE: begin
                        kt = 28;
                        PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                    end
                    default: begin
                        killD_req_next = 1'b0;
                        killD2_req_next = 1'b0;
                        killX_req_next = 1'b0;
                        
                        // PCF next
                        if (PCSel_F == 1'b0) begin
                            kt = 29;
                            PCSel_F_out = 3'd0; 
                        end else begin
                            kt = 30;
                            PCSel_F_out = 3'd1; 
                        end
                    end
                    endcase
                end else begin
                    killD_req_next = 1'b1;
                    killD2_req_next = 1'b1;
                    killX_req_next = 1'b0;
                    PCSel_F_out = 3'd4; // PCD + 4
                end
            end
        end
        default: begin
            return_valid = 1'b0;
            case (instF[6:2])
            JAL_TYPE: begin
                kt = 31;
                killD_req_next = 1'b0;
                killD2_req_next = 1'b0;
                killX_req_next = 1'b0;
                PCSel_F_out = 3'd1; // PC + ImF
            end
            JALR_TYPE: begin
                kt = 32;
                killD_req_next = 1'b0;
                killD2_req_next = 1'b0;
                killX_req_next = 1'b0;
                PCSel_F_out = 3'd0; // PC + 4 // Guest
            end
            B_TYPE: begin
                kt = 33;
                PCSel_F_out = {{2'd0}, ~predict_not_jump};//3'd0; // Static predict not jump
                killD_req_next = 1'b0;
                killD2_req_next = 1'b0;
                killX_req_next = 1'b0;
            end
            default: begin
                killD_req_next = 1'b0;
                killD2_req_next = 1'b0;
                killX_req_next = 1'b0;
                
                // PCF next
                if (PCSel_F == 1'b0) begin
                    kt = 34;
                    PCSel_F_out = 3'd0; 
                end else begin
                    kt = 35;
                    PCSel_F_out = 3'd1; 
                end
            end
            endcase
        end
        endcase
    end
endcase
end
endcase
end
always @(posedge clk)
begin
if (return_valid == 1'b1) begin
    case (state)
    2'd0: begin
        if (return_jump == 1'b1) begin
            state = 2'd0;
            predict_not_jump = 0;
        end else begin
            state = 2'd1;
            predict_not_jump = 0;
        end
    end
    2'd1: begin
        if (return_jump == 1'b1) begin
            state = 2'd0;
            predict_not_jump = 0;
        end else begin
            state = 2'd2;
            predict_not_jump = 1;
        end    
    end
    2'd2: begin
        if (return_jump == 1'b1) begin
            state = 2'd3;
            predict_not_jump = 1;
        end else begin
            state = 2'd2;
            predict_not_jump = 1;
        end    
    end
    2'd3: begin
        if (return_jump == 1'b1) begin
            state = 2'd0;
            predict_not_jump = 0;
        end else begin
            state = 2'd2;
            predict_not_jump = 1;
        end    
    end
    endcase
end
end

/*
0: Hard Jump
1: Soft Jump
2: Hard Not Jump
3: Soft Not Jump
*/

initial begin
    killD_req_next = 0;
    killD2_req_next = 1'b0;
    killX_req_next = 0;
    PCSel_F_out = 3'd0;
    state = 0;
    return_jump = 1;
    predict_not_jump = 1;
    return_valid = 0;
end
endmodule

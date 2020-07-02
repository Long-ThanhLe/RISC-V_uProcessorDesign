`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/29/2020 12:14:16 PM
// Design Name: 
// Module Name: static_branch
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


module static_branch(
    instF,
    instD,
    instE,
    killF,
    killD, 
    killE,
    pcmux_sel_X,
    pcmux_sel_F,
    predict_fail,
    pcmux_sel_out,
    stall_in,
    stall_out
    );
input [31:0] instE, instD, instF;
input pcmux_sel_X, pcmux_sel_F, killD, killF, killE, stall_in;
output reg [2:0] pcmux_sel_out;
output reg predict_fail, stall_out;
reg pcmux_sel_D_out;

parameter B_TYPE = 5'b11000;
parameter JAL_TYPE = 5'b11011;
parameter JALR_TYPE = 5'b11001;


always @(*) 
begin
    if (stall_in == 1'b0) begin
        stall_out = 1'b0;
        if (killE == 1'b0) begin // E stage is not kill
            case (instE[6:2])
            B_TYPE: begin
                if (pcmux_sel_X == 1'b1) // Wrong predict
                begin
                    predict_fail = 1'b1;
                    pcmux_sel_out = 3'd5; // Branch
                end
                else // as predict -> PC + 4
                begin
                    predict_fail = 1'b0;
                    if (killF == 1'b0) begin
                        case (instF[6:2])
                        B_TYPE: begin
                            pcmux_sel_out = 3'd0; // Not taken
                        end
                        JAL_TYPE: begin
                            pcmux_sel_out = 3'd3; // Not taken
                        end
                        JALR_TYPE: begin
                            pcmux_sel_out = 3'd0; // Not taken
                        end
                        default: begin
                            
                            pcmux_sel_out = {{2'd0},pcmux_sel_F};    
                        end
                        endcase
                    end else begin
                        // Not happen
                    end
                end
            end
            default: begin
                if (killD == 1'b0) begin // D stage is not kill
                    case (instD[6:2])
                    // JAL_TYPE: begin
                    //     predict_fail = 1'b0;
                    //     pcmux_sel_out = 3'd3;
                    // end
                    JALR_TYPE: begin
                        predict_fail = 1'b0;
                        pcmux_sel_out = 3'd4;
                    end
                    default: begin // Predict
                        predict_fail = 1'b0;
                        if (killF == 1'b0) begin
                            case (instF[6:2])
                            B_TYPE: begin
                                pcmux_sel_out = 3'd0; // Not taken
                            end
                            JAL_TYPE: begin
                                pcmux_sel_out = 3'd3; // Not taken
                            end
                            JALR_TYPE: begin
                                pcmux_sel_out = 3'd0; // Not taken
                            end
                            default: begin
                                
                                pcmux_sel_out = {{2'd0},pcmux_sel_F};    
                            end
                            endcase
                        end else begin
                            // Not happen
                        end
                    end
                    endcase
                end else begin
                    predict_fail = 1'b0;
                    if (killF == 1'b0) begin
                        case (instF[6:2])
                        B_TYPE: begin
                            pcmux_sel_out = 3'd0; // Not taken
                        end
                        JAL_TYPE: begin
                            pcmux_sel_out = 3'd3; // Not taken
                        end
                        JALR_TYPE: begin
                            pcmux_sel_out = 3'd0; // Not taken
                        end
                        default: begin
                            
                            pcmux_sel_out = {{2'd0},pcmux_sel_F};    
                        end
                        endcase
                    end else begin
                        // Not happen
                    end

                end
            end
            endcase

        end else begin
            
            if (killD == 1'b0) begin // D stage is not kill
                case (instD[6:2])
                // JAL_TYPE: begin
                //     predict_fail = 1'b0;
                //     pcmux_sel_out = 3'd3;
                // end
                JALR_TYPE: begin
                    predict_fail = 1'b0;
                    pcmux_sel_out = 3'd4;
                end
                default: begin // Predict
                    predict_fail = 1'b0;
                    if (killF == 1'b0) begin
                        case (instF[6:2])
                        B_TYPE: begin
                            pcmux_sel_out = 3'd0; // Not taken
                        end
                        JAL_TYPE: begin
                            pcmux_sel_out = 3'd3; // Not taken
                        end
                        JALR_TYPE: begin
                            pcmux_sel_out = 3'd0; // Not taken
                        end
                        default: begin
                            
                            pcmux_sel_out = {{2'd0},pcmux_sel_F};    
                        end
                        endcase
                    end else begin
                        // Not happen
                    end
                end
                endcase
            end else begin
                predict_fail = 1'b0;
                if (killF == 1'b0) begin
                    case (instF[6:2])
                    B_TYPE: begin
                        pcmux_sel_out = 3'd0; // Not taken
                    end
                    JAL_TYPE: begin
                        pcmux_sel_out = 3'd3; // Not taken
                    end
                    JALR_TYPE: begin
                        pcmux_sel_out = 3'd0; // Not taken
                    end
                    default: begin
                        pcmux_sel_out = {{2'd0},pcmux_sel_F};    
                    end
                    endcase
                end else begin
                    // Not happen
                end

            end

        end
    end else begin
        stall_out = 1'b1;
    end
end

endmodule
